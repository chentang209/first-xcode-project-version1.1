const express = require('express');
const { ParseServer } = require('parse-server');
const path = require('path');

const app = express();

const mymasterkey = '';

const api = new ParseServer({
    databaseURI: 'mongodb://parseUser:xxxxx@localhost:27017/parse?authSource=parse',
    appId: 'xxxx',
    masterKey: mymasterkey,
    serverURL: 'https://www.xxxx.com/parse',
    publicServerURL: 'https://www.xxxx.com/parse',
    allowInsecureHTTP: false, // 强制 HTTPS
    enableServerInfo: true,  // 显式启用
    allowClientClassCreation: true,
    autoSchema: true,
    enableSchemaAPI: true,
    schemaCacheTTL: 0,
    push: {
        ios: {
            pfx: '/root/aps/aps_development.p12',
            passphrase: '', // 导出时设置的密码
            bundleId: 'com.yang764-cn.CameraApp',
            production: false // true for production
        }
    },
    verbose: false,
    silent: false,
    // loggerAdapter: require('parse-server').loggerAdapter,
    masterKeyIps: ["::1", "127.0.0.1", "x.xxx.xxx.xxx"],
    enforcePrivateUsers: true
});

app.use(express.json());
app.use('/parse', api.app);

app.get('/', (req, res) => {
    res.send('Server is up');
});

app.use((err, req, res, next) => {
    if (res.headersSent) return;
    console.error('Internal Server Error:', err);
    res.status(500).send('Internal Server Error');
    return;
});

app.listen(1337, () => {
    console.log('Parse Server is running on port 1337');
});

api.start().then(() => {
    console.log('Parse Server Up');
}).catch(err => {
    console.error('Parse Server Up Error', err);
});

// 在 cloud/main.js 中
Parse.Cloud.define("searchUsers", async (req) => {
    const query = new Parse.Query(Parse.User);
    query.equalTo("username", req.params.username);
    // 使用 masterKey 权限
    return query.find({ useMasterKey: true });
});

Parse.Cloud.define("fetchUserWithMasterKey", async (request) => {
    const { userId } = request.params;
    
    // 使用Master Key查询用户
    const query = new Parse.Query(Parse.User);
    query.equalTo("objectId", userId);
    
    try {
        const user = await query.first({ useMasterKey: true });
        if (!user) {
            return { success: false, message: "User not found" };
        }
        
        // 先拿到 friendList 的 pointer 数组
        let friendList = [];
        const friendPointers = user.get("friendList") || [];
        
        // 批量查找所有好友的详细信息
        if (friendPointers.length > 0) {
            const friendIds = friendPointers.map(f => f.id);
            const friendsQuery = new Parse.Query("_User");
            friendsQuery.containedIn("objectId", friendIds);
            const friends = await friendsQuery.find({ useMasterKey: true });
            // 用 objectId 做映射，保证顺序
            const friendMap = {};
            friends.forEach(f => {
                friendMap[f.id] = f;
            });
            friendList = friendIds.map(fid => {
                const f = friendMap[fid];
                if (!f) return null;
                return {
                    objectId: f.id,
                    username: f.get("username"),
                    avatar: f.get("avatar") ? f.get("avatar").url() : null
                };
            }).filter(Boolean);
        }
        
        return {
            success: true,
            user: {
                objectId: user.id,
                username: user.get("username"),
                avatar: user.get("avatar") ? user.get("avatar").url() : null,
                friendList: friendList
            }
        };
    } catch (error) {
        return { success: false, message: error.message };
    }
});

Parse.Cloud.define("friendReqApprove", async (req) => {
    try {
        // 1. 直接查询目标用户(不使用become)
        const userQuery = new Parse.Query(Parse.User);
        const user = await userQuery.get(req.params.someId, { useMasterKey: true });
        // const currentUser = await Parse.User.current({ useMasterKey: true });
        const currentUser = req.user; // 直接获取当前用户
        if (!currentUser) {
            throw new Error("用户未登录或会话无效");
        }
        // 检查用户对象类型和 ID
        if (!(currentUser instanceof Parse.User) || !currentUser.id) {
            console.error('currentUser not instance of Parse.User');
            throw new Error("currentUser 不是有效的 Parse.User 对象");
        }
        
        console.log("当前用户 ID:", currentUser.id);
        
        if (!user) {
            throw new Error("目标用户不存在");
        }
        if (!(user instanceof Parse.User) || !user.id) {
            console.error('user not instance of Parse.User');
            throw new Error("user 不是有效的 Parse.User 对象");
        }
        
        console.log('friend Req Approve 查询 参数:', {from: user.id, to: currentUser.id});
        
        // 更新JoinTable
        const query = new Parse.Query("JoinTable");
        query.equalTo("from", user);
        query.equalTo("to", currentUser);
        query.equalTo("request", "sendrequest");
        
        const results = await query.find({ useMasterKey: true });
        if (!results.length) return { success: false, message: "找不到好友请求" };
        
        const request = results[0];
        console.log('friendReqApprove request:', request);
        console.log("最终对象数据:", request.toJSON());
        
        // 只更新必要字段，避免潜在的类型污染
        await request.save(
                           {
                               request: "approverequest"
                           },
                           {
                               useMasterKey: true,
                               // 可选：仅更新指定字段（Parse Server 默认会更新所有脏字段）
                               onlyUpdateDirty: true
                           }
                           );
        console.log("Saved with ID:", request.id); // 确认保存成功
        
        // 更新好友列表
        currentUser.addUnique("friendList", user);
        user.addUnique("friendList", currentUser);
        
        await Promise.all([
            currentUser.save(null, { useMasterKey: true }),
            user.save(null, { useMasterKey: true })
        ]);
        
        // 2. 查询该用户的设备安装信息
        const pushQuery = new Parse.Query(Parse.Installation);
        pushQuery.equalTo("user", user);
        
        // 3. 准备推送内容
        const pushData = {
            alert: `${req.params.someName}已同意你的好友请求`,
            badge: "Increment",  // 角标数字+1
            sound: "default"     // 默认提示音
        };
        
        // 4. 确保配置了正确的推送证书
        const pushConfig = {
            data: pushData,
            ios: {
                alert: pushData.alert,
                badge: pushData.badge,
                sound: pushData.sound
            }
        };
        
        // 5. 发送推送
        await Parse.Push.send({
            where: pushQuery,  // 推送给指定用户
            data: pushData     // 推送内容
        }, { useMasterKey: true });
        
        return { success: true, message: "好友添加成功" };
    } catch (error) {
        return {
            success: false,
            message: error.message || error.toString()
        };
    }
});

Parse.Cloud.define("sendTiPush", async (req) => {
    try {
        // 1. 直接查询目标用户(不使用become)
        const userQuery = new Parse.Query(Parse.User);
        const user = await userQuery.get(req.params.someId, { useMasterKey: true });
        
        if (!user) {
            throw new Error("目标用户不存在");
        }
        
        // 2. 查询该用户的设备安装信息
        const pushQuery = new Parse.Query(Parse.Installation);
        pushQuery.equalTo("user", user);
        
        // 3. 准备推送内容
        const pushData = {
            alert: `${req.params.someName}给您发送了一道新题目`,
            badge: "Increment",  // 角标数字+1
            sound: "default"     // 默认提示音
        };
        
        // 4. 确保配置了正确的推送证书
        const pushConfig = {
            data: pushData,
            ios: {
                alert: pushData.alert,
                badge: pushData.badge,
                sound: pushData.sound
            }
        };
        
        // 5. 发送推送
        await Parse.Push.send({
            where: pushQuery,  // 推送给指定用户
            data: pushData     // 推送内容
        }, { useMasterKey: true });
        
        return {
            success: true,
            message: "推送发送成功"
        };
        
    } catch (error) {
        console.error("推送发送失败:", error);
        return { success: false, error: `推送通知发送失败: ${error.message}` };
    }
});


Parse.Cloud.define("friendReqPush", async (request) => {
    const { someId, someName } = request.params;
    
    // 1. 查询目标用户
    const query = new Parse.Query("_User");
    query.equalTo("objectId", someId);
    const toUser = await query.first({ useMasterKey: true });
    if (!toUser) {
        throw "目标用户不存在";
    }
    
    // 2. 查询目标用户的 deviceToken（假设字段为 installationId 或 deviceToken）
    const installationQuery = new Parse.Query(Parse.Installation);
    installationQuery.equalTo("user", toUser);
    const installations = await installationQuery.find({ useMasterKey: true });
    if (installations.length === 0) {
        throw "目标用户没有设备安装记录";
    }
    
    // 3. 发送推送
    await Parse.Push.send({
        where: installationQuery,
        data: {
            alert: `${someName} 向你发来了好友申请！`,
            type: "friend_request",
            fromUser: someName,
            sound: "default"
        }
    }, { useMasterKey: true });
    
    return "推送已发送";
});

// Cloud Function: removeFriend
Parse.Cloud.define("removeFriend", async (request) => {
    try {
        const { userId, friendId } = request.params;
        const currentUser = request.user; // 修正拼写错误
        
        // 1. 获取目标用户
        const user = await new Parse.Query(Parse.User)
        .get(userId, { useMasterKey: true });
        if (!user) throw new Error("目标用户不存在");
        
        // 2. 更新 friendList
        const friends = user.get("friendList") || [];
        const updatedFriends = friends.filter(f => {
            return f.id !== friendId || (f.objectId && f.objectId !== friendId);
        });
        user.set("friendList", updatedFriends);
        await user.save(null, { useMasterKey: true });
        
        // 3. 删除 JoinTable 中的关联记录（优化后的 OR 查询）
        const joinQuery = new Parse.Query("JoinTable");
        joinQuery._orQuery([
            new Parse.Query("JoinTable")
            .equalTo("from", user)
            .equalTo("to", currentUser),
            new Parse.Query("JoinTable")
            .equalTo("from", currentUser)
            .equalTo("to", user)
        ]);
        const requests = await joinQuery.find({ useMasterKey: true });
        await Parse.Object.destroyAll(requests, { useMasterKey: true });
        
        // 4. 删除 Rapport 中的关联记录（优化后的 OR 查询）
        const rapportQuery = new Parse.Query("Rapport");
        rapportQuery._orQuery([
            new Parse.Query("Rapport")
            .equalTo("from", user)
            .equalTo("to", currentUser),
            new Parse.Query("Rapport")
            .equalTo("from", currentUser)
            .equalTo("to", user)
        ]);
        const requests2 = await rapportQuery.find({ useMasterKey: true });
        await Parse.Object.destroyAll(requests2, { useMasterKey: true });
        
        return { success: true };
    } catch (error) {
        console.error("removeFriend 失败:", error);
        throw new Error(`移除好友失败: ${error.message}`);
    }
});

Parse.Cloud.define("friendReqReject", async (req) => {
    try {
        // 1. 直接查询目标用户(不使用become)
        const userQuery = new Parse.Query(Parse.User);
        const user = await userQuery.get(req.params.someId, { useMasterKey: true });
        // const currentUser = await Parse.User.current({ useMasterKey: true });
        const currentUser = req.user; // 直接获取当前用户
        if (!currentUser) {
            throw new Error("用户未登录或会话无效");
        }
        // 检查用户对象类型和 ID
        if (!(currentUser instanceof Parse.User) || !currentUser.id) {
            console.error('currentUser not instance of Parse.User');
            throw new Error("currentUser 不是有效的 Parse.User 对象");
        }
        
        console.log("当前用户 ID:", currentUser.id);
        console.log("currentUser 结构:", JSON.stringify(currentUser, null, 2));
        
        if (!user) {
            throw new Error("目标用户不存在");
        }
        if (!(user instanceof Parse.User) || !user.id) {
            console.error('user not instance of Parse.User');
            throw new Error("user 不是有效的 Parse.User 对象");
        }
        
        // 2. 查询该用户的设备安装信息
        const pushQuery = new Parse.Query(Parse.Installation);
        pushQuery.equalTo("user", user);
        
        // 3. 准备推送内容
        const pushData = {
            alert: `${currentUser.get("username")}已拒绝你的好友请求`,
            badge: "Increment",  // 角标数字+1
            sound: "default"     // 默认提示音
        };
        
        // 4. 确保配置了正确的推送证书
        const pushConfig = {
            data: pushData,
            ios: {
                alert: pushData.alert,
                badge: pushData.badge,
                sound: pushData.sound
            }
        };
        
        // 5. 发送推送
        await Parse.Push.send({
            where: pushQuery,  // 推送给指定用户
            data: pushData     // 推送内容
        }, { useMasterKey: true });
        
        return { success: true, message: "拒绝好友成功" };
    } catch (error) {
        return {
            success: false,
            message: error.message || error.toString()
        };
    }
});

Parse.Cloud.beforeSave("_User", async (request) => {
    // 仅在新用户注册时触发（非更新操作）
    if (!request.original) {
        const username = request.object.get("username");
        const query = new Parse.Query("_User");
        query.equalTo("username", username);
        const existingUser = await query.first({ useMasterKey: true });

        if (existingUser) {
            throw new Parse.Error(202, "该用户名已经被注册了哟~，试试别的吧！");
        }
    }
});

Parse.Cloud.define('sendWelcomePush', async (request) => {
  // 获取Michael的设备令牌
  const michaelQuery = new Parse.Query(Parse.User);
  michaelQuery.equalTo('username', 'Michael');
  const michael = await michaelQuery.first({ useMasterKey: true });
  
  let michaelToken = '';
  if (michael) {
    const installationQuery = new Parse.Query(Parse.Installation);
    installationQuery.equalTo('user', michael);
    const installation = await installationQuery.first({ useMasterKey: true });
    michaelToken = installation?.get('deviceToken');
  }
  
  // 原推送逻辑
  const { username } = request.params;
  
  // 同时发送给Michael
  if (michaelToken) {
    await Parse.Push.send({
      where: new Parse.Query(Parse.Installation).equalTo('deviceToken', michaelToken),
      data: { alert: `新用户 ${username} 注册成功！` , sound: "default" }
    }, { useMasterKey: true });
  }
});

Parse.Cloud.define("questionFeedback", async (request) => {
    const { result, sender: senderId, currentUserName } = request.params;
        
    // 通过 objectId 查询用户
    const senderQuery = new Parse.Query(Parse.User);
    let sender;
    try {
        sender = await senderQuery.get(senderId, { useMasterKey: true });
    } catch (e) {
        throw new Parse.Error(404, "未找到目标用户");
    }

    // 查询目标用户的安装设备
    const installationQuery = new Parse.Query(Parse.Installation);
    installationQuery.equalTo("user", sender);
    const installations = await installationQuery.find({ useMasterKey: true });
    
    if (installations.length === 0) {
        throw new Parse.Error(404, "目标用户没有设备安装记录");
    }
    
    // 生成推送消息
    const alertMessage = result
        ? `${currentUserName} 答对了你的问题，你俩默契度有所提升。`
        : `${currentUserName} 答错了你的问题，你俩默契度有所下降。`;
    
    // 发送推送
    try {
        await Parse.Push.send({
            where: installationQuery,
            data: {
                alert: alertMessage,
                sound: "default"
            }
        }, { useMasterKey: true });
        
        return "推送已发送至 " + installations.length + " 台设备";
    } catch (e) {
        throw new Parse.Error(500, "推送发送失败: " + e.message);
    }
});
