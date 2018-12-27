import Xhist.*;
package io.left.meshim.controllers;
 
import static io.left.rightmesh.mesh.MeshManager.ADDED;
import static io.left.rightmesh.mesh.MeshManager.DATA_DELIVERED;
import static io.left.rightmesh.mesh.MeshManager.DATA_RECEIVED;
import static io.left.rightmesh.mesh.MeshManager.PEER_CHANGED;
import static io.left.rightmesh.mesh.MeshManager.REMOVED;
import static io.left.rightmesh.mesh.MeshManager.UPDATED;
import static protobuf.MeshIMMessages.MessageType.MESSAGE;
import static protobuf.MeshIMMessages.MessageType.PEER_UPDATE;
 
import android.content.Context;
import android.os.RemoteException;
 
import com.google.protobuf.InvalidProtocolBufferException;
 
import io.left.meshim.R;
import io.left.meshim.activities.IActivity;
import io.left.meshim.database.MeshIMDao;
import io.left.meshim.models.MeshIdTuple;
import io.left.meshim.models.Message;
import io.left.meshim.models.User;
import io.left.meshim.services.MeshIMService;
import io.left.rightmesh.android.AndroidMeshManager;
import io.left.rightmesh.id.MeshId;
import io.left.rightmesh.mesh.MeshManager;
import io.left.rightmesh.mesh.MeshManager.DataReceivedEvent;
import io.left.rightmesh.mesh.MeshManager.PeerChangedEvent;
import io.left.rightmesh.mesh.MeshManager.RightMeshEvent;
import io.left.rightmesh.mesh.MeshStateListener;
import io.left.rightmesh.util.RightMeshException;
 
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
 
import protobuf.MeshIMMessages;
import protobuf.MeshIMMessages.MeshIMMessage;
import protobuf.MeshIMMessages.MessageType;
import protobuf.MeshIMMessages.PeerUpdate;
 
/** 
 * All RightMesh logic abstracted into one class to keep it separate from Android logic. 
 */ 
public class RightMeshController implements MeshStateListener {
    // Port to bind app to. 
    private static final int MESH_PORT = 54321;
 
    // MeshManager instance - interface to the mesh network. 
    private AndroidMeshManager meshManager = null;
 
    // Set to keep track of peers connected to the mesh. 
    private HashSet<MeshId> discovered = new HashSet<>();
    private HashMap<MeshId, User> users = new HashMap<>();
    private User user = null;
 
    // Database interface. 
    private MeshIMDao dao;
 
    // Link to current activity. 
    private IActivity callback = null;
    //reference to service 
    private MeshIMService meshIMService;
    // keeps track of all the undeliveredPackages. 
    private HashMap<Integer, Integer> unDeliveredMessageIds = new HashMap<Integer, Integer>();
    private ConcurrentMap<Integer,MeshId> undeliveredPeerUpdateMessages = new ConcurrentHashMap<>();
 
    // a timer and a boolean to make sure there is only ever one timer running at a time 
    // for undelivered packages. 
    private Timer undeliveredPackageTimer;
    private boolean isTimerRunning = false;
    private final int UNDELIVERED_PACKAGE_TIMEOUT = 8000;
    /** 
     * Constructor. 
     * @param user user info for this device 
     * @param dao DAO instance from open database connection 
     * @param meshIMService link to service instance 
     */ 
    public RightMeshController(User user, MeshIMDao dao,
                               MeshIMService meshIMService) { 
        this.user = user;	Xhist.add( 1, 88 );
        this.dao = dao;	Xhist.add( 1, 89 );
        this.meshIMService = meshIMService;	Xhist.add( 1, 90 );
 
        new Thread(() -> { 
            if (dao.fetchAllUsers().length == 0) { 
                // Insert this device's user as the first user on first run. 
                this.dao.insertUsers(user);	Xhist.add( 1, 95 );
            } else { 
                // Otherwise make sure the database is up to date with SharedPreferences. 
                this.dao.updateUsers(user);	Xhist.add( 1, 98 );
            } 
        }).start();	Xhist.add( 1, 100 );
        undeliveredPackageTimer = new Timer();	Xhist.add( 1, 101 );
    } 
 
    public void setCallback(IActivity callback) { 
        this.callback = callback;	Xhist.add( 1, 105 );
        updateInterface();	Xhist.add( 1, 106 );
    } 
 
    /** 
     * Returns a list of online users. 
     * @return online users 
     */ 
    public List<User> getUserList() { 
        return new ArrayList<>(users.values());
    } 
 
    /** 
     * Sends a simple text message to another user. 
     * @param recipient recipient of the message 
     * @param message contents of the message 
     */ 
    public void sendTextMessage(User recipient, String message) { 
        Message messageObject = new Message(user, recipient, message, true);
        try { 
            byte[] messagePayload = createMessagePayloadFromMessage(messageObject);	Xhist.add( 1, 125 );
            if (messagePayload != null) { 
                int deliveryDataId = meshManager.sendDataReliable(recipient.getMeshId(), MESH_PORT, messagePayload);
                long insertedMessageInfo[] = dao.insertMessages(messageObject);
                //save the id of the message in the hashmap. 
                unDeliveredMessageIds.put(deliveryDataId, (int) insertedMessageInfo[0]);	Xhist.add( 1, 130 );
                updateInterface();	Xhist.add( 1, 131 );
            } 
        } catch (RightMeshException ignored) { 
            // Something has gone wrong sending the message. 
            // Don't store it in database or update UI. 
        } 
    } 
 
    /** 
     * Get a {@link AndroidMeshManager} instance, starting RightMesh if it isn't already running. 
     * 
     * @param context service context to bind to 
     */ 
    public void connect(Context context) { 
        meshManager = AndroidMeshManager.getInstance(context, RightMeshController.this);	Xhist.add( 1, 145 );
    } 
 
    /** 
     * Close the RightMesh connection, stopping the service if no other apps are running. 
     */ 
    public void disconnect() { 
        try { 
            if (meshManager != null) { 
                meshManager.stop();	Xhist.add( 1, 154 );
            } 
        } catch (RightMeshException.RightMeshServiceDisconnectedException ignored) { 
            // Error encountered shutting down service - nothing we can do from here. 
        } 
    } 
 
    /** 
     * Called by the {@link MeshService} when the mesh state changes. Initializes mesh connection 
     * on first call. 
     * 
     * @param uuid  our own user id on first detecting 
     * @param state state which indicates SUCCESS or an error code 
     */ 
    @Override 
    public void meshStateChanged(MeshId uuid, int state) { 
        if (state == MeshStateListener.SUCCESS) { 
            // Update stored user preferences with current MeshId. 
            user.setMeshId(uuid);	Xhist.add( 1, 172 );
            user.save(meshIMService);	Xhist.add( 1, 173 );
            try { 
                // Binds this app to MESH_PORT. 
                // This app will now receive all events generated on that port. 
                meshManager.bind(MESH_PORT);	Xhist.add( 1, 177 );
            } catch (RightMeshException e) { 
                // @TODO: App can't receive notifications. This needs to be alerted somehow. 
            } 
 
            // Subscribes handlers to receive events from the mesh. 
            meshManager.on(DATA_RECEIVED, this::handleDataReceived);	Xhist.add( 1, 183 );
            meshManager.on(PEER_CHANGED, this::handlePeerChanged);	Xhist.add( 1, 184 );
            meshManager.on(DATA_DELIVERED, this::handleDataDelivery);	Xhist.add( 1, 185 );
 
            // Update the UI for the first time. 
            updateInterface();	Xhist.add( 1, 188 );
        } 
    } 
 
    /** 
     * Exception boilerplate around {@link IActivity#updateInterface()}. 
     */ 
    private void updateInterface() { 
        try { 
            if (callback != null) { 
                callback.updateInterface();	Xhist.add( 1, 198 );
            } 
        } catch (RemoteException ignored) { 
            // Connection to interface has broken - nothing we can do from here. 
        } 
    } 
 
    /** 
     * Handles incoming data events from the mesh. 
     * 
     * <p> 
     *     All messages should be ProtoBuf {@link MeshIMMessage}s. If of type PEER_UPDATE, will 
     *     update the peer in the database with the newly supplied information. If of type MESSAGE, 
     *     adds the message to the database and sends a notification. 
     * </p> 
     * 
     * @param e event object from RightMesh 
     */ 
    private void handleDataReceived(RightMeshEvent e) { 
        DataReceivedEvent event = (DataReceivedEvent) e;
 
        try { 
            MeshIMMessage messageWrapper = MeshIMMessage.parseFrom(event.data);
            MeshId peerId = event.peerUuid;
 
            if (peerId.equals(meshManager.getUuid())) { 
                return;
            } 
 
            MessageType messageType = messageWrapper.getMessageType();
            if (messageType == PEER_UPDATE) { 
                PeerUpdate peerUpdate = messageWrapper.getPeerUpdate();
 
                // Initialize peer with info from update packet. 
                User peer = new User(peerUpdate.getUserName(), peerUpdate.getAvatarId(), peerId);
 
                // Create or update user in database. 
                MeshIdTuple dietPeer = dao.fetchMeshIdTupleByMeshId(peerId);
                if (dietPeer == null) { 
                    dao.insertUsers(peer);	Xhist.add( 1, 237 );
 
                    // Fetch the user's id after it is initialized. 
                    dietPeer = dao.fetchMeshIdTupleByMeshId(peerId);	Xhist.add( 1, 240 );
                    peer.id = dietPeer.id;	Xhist.add( 1, 241 );
                } else { 
                    peer.id = dietPeer.id;	Xhist.add( 1, 243 );
                    dao.updateUsers(peer);	Xhist.add( 1, 244 );
                } 
 
                // Store user in list of online users. 
                users.put(peerId, peer);	Xhist.add( 1, 248 );
                updateInterface();	Xhist.add( 1, 249 );
            } else if (messageType == MESSAGE) { 
                MeshIMMessages.Message protoMessage = messageWrapper.getMessage();	Xhist.add( 1, 251 );
 
                // Try to find user details, fetching from database if they aren't in the online 
                // users list. 
                User sender = users.get(peerId);
                if (sender == null) { 
                    sender = dao.fetchUserByMeshId(peerId);	Xhist.add( 1, 257 );
                } 
 
                if (sender != null && user != null) { 
                    Message message = new Message(sender, user, protoMessage.getMessage(), false);
                    // message has been delivered 
                    message.setDelivered(true);	Xhist.add( 1, 263 );
                    dao.insertMessages(message);	Xhist.add( 1, 264 );
                    meshIMService.sendNotification(sender, message);	Xhist.add( 1, 265 );
                    updateInterface();	Xhist.add( 1, 266 );
                } 
            } 
        } catch (InvalidProtocolBufferException ignored) { /* Ignore malformed messages. */ } 
    } 
 
    /** 
     * Handles peer update events from the mesh - maintains a list of peers and updates the display. 
     * 
     * @param e event object from mesh 
     */ 
    private void handlePeerChanged(RightMeshEvent e) { 
        // Update peer list. 
        PeerChangedEvent event = (PeerChangedEvent) e;
 
        // Ignore ourselves. 
        if (event.peerUuid.equals(meshManager.getUuid())) { 
            return;
        } 
 
        if (!discovered.contains(event.peerUuid) 
                && (event.state == ADDED || event.state == UPDATED)) { 
            discovered.add(event.peerUuid);	Xhist.add( 1, 288 );
            // let the user know mesh has discovered a new user, and is getting details. 
            User tempUser = new User(meshIMService.getString(R.string.get_user_details), R.mipmap.account_default);
            users.put(event.peerUuid, tempUser);	Xhist.add( 1, 291 );
            updateInterface();	Xhist.add( 1, 292 );
        } 
 
        if (event.state == ADDED) { 
            // Send our information to a new or rejoining peer. 
            byte[] message = createPeerUpdatePayloadFromUser(user);	Xhist.add( 1, 297 );
            try { 
                if (message != null) { 
                   int dataId = meshManager.sendDataReliable(event.peerUuid, MESH_PORT, message);
                   //making the status of the message undelivered so we can resend the package if delivery 
                    // report is not recieved. 
                   undeliveredPeerUpdateMessages.put(dataId,event.peerUuid);	Xhist.add( 1, 303 );
                   // schedule a task to resend undelivered peer updates. 
                   resendUndeliveredPackages();	Xhist.add( 1, 305 );
                } 
            } catch (RightMeshException ignored) { 
                // Message sending failed. Other user may have out of date information, but 
                // ultimately this isn't deal-breaking. 
            } 
        } else if (event.state == REMOVED) { 
            discovered.remove(event.peerUuid);	Xhist.add( 1, 312 );
            users.remove(event.peerUuid);	Xhist.add( 1, 313 );
            updateInterface();	Xhist.add( 1, 314 );
        } 
    } 
 
    /** 
     * Creates a byte array representing a {@link User}, to be broadcast over the mesh. 
     * @param user user to be represented in bytes 
     * @return payload to be broadcast 
     */ 
    private byte[] createPeerUpdatePayloadFromUser(User user) { 
        if (user == null) { 
            return null;
        } 
 
        PeerUpdate peerUpdate = PeerUpdate.newBuilder() 
                .setUserName(user.getUsername()) 
                .setAvatarId(user.getAvatar()) 
                .build();	Xhist.add( 1, 331 );
 
        MeshIMMessage message = MeshIMMessage.newBuilder() 
                .setMessageType(PEER_UPDATE) 
                .setPeerUpdate(peerUpdate) 
                .build();	Xhist.add( 1, 336 );
 
        return message.toByteArray();
    } 
 
    /** 
     * Creates a byte array representing a {@link Message}, to be broadcast over the mesh. 
     * @param message message to be represented in bytes 
     * @return payload to be broadcast 
     */ 
    private byte[] createMessagePayloadFromMessage(Message message) { 
        if (message == null) { 
            return null;
        } 
 
        MeshIMMessages.Message protoMsg = MeshIMMessages.Message.newBuilder() 
                .setMessage(message.getMessage()) 
                .setTime(message.getDateAsTimestamp()) 
                .build();	Xhist.add( 1, 354 );
 
        MeshIMMessage payload = MeshIMMessage.newBuilder() 
                .setMessageType(MESSAGE) 
                .setMessage(protoMsg) 
                .build();	Xhist.add( 1, 359 );
 
        return payload.toByteArray();
    } 
 
    /** 
     * Load the updated user profile and broadcast it to all connected peers. 
     */ 
    public void broadcastProfile() { 
        if (user.load(meshIMService)) { 
            byte[] message = createPeerUpdatePayloadFromUser(user);	Xhist.add( 1, 369 );
            if (message != null) { 
                for (MeshId id : users.keySet()) { 
                    try { 
                        meshManager.sendDataReliable(id, MESH_PORT, message);	Xhist.add( 1, 373 );
                    } catch (RightMeshException e) { 
                        // Message sending failed. Other user may have out of date information, but 
                        // ultimately this isn't deal-breaking. 
                    } 
                } 
            } 
        } 
    } 
 
    /** 
     * Displays Rightmesh setting page. 
     */ 
    public void showRightMeshSettings() { 
        try { 
            meshManager.showSettingsActivity();	Xhist.add( 1, 388 );
        } catch (RightMeshException ignored) { 
            // Service failed loading settings - nothing to be done. 
        } 
    } 
 
    /** 
     * Handles data delivery event from the mesh. Updates the hashmap that stores the  Ids of 
     * undelivered packages. 
     * @param e event object from mesh. 
     */ 
    void handleDataDelivery(RightMeshEvent e) { 
        MeshManager.DataDeliveredEvent event = (MeshManager.DataDeliveredEvent) e;	Xhist.add( 1, 400 );
        final int deliveryDataId = event.data_id;
        if(unDeliveredMessageIds.containsKey(deliveryDataId)){ 
            //updating the message delivery status in the database 
            dao.updateMessageIsDelivered(unDeliveredMessageIds.get(deliveryDataId));	Xhist.add( 1, 404 );
            unDeliveredMessageIds.remove(deliveryDataId);	Xhist.add( 1, 405 );
            updateInterface();	Xhist.add( 1, 406 );
        } 
        else if(undeliveredPeerUpdateMessages.containsKey(deliveryDataId)){ 
            // removing the message from undeliveredPeerUpdate map since we dont need to send it again. 
            undeliveredPeerUpdateMessages.remove(deliveryDataId);	Xhist.add( 1, 410 );
        } 
    } 
 
    /** 
     * Runs a timer task when there are undelivered peer updates in the que 
     */ 
    void resendUndeliveredPackages(){ 
        if(!isTimerRunning && !undeliveredPeerUpdateMessages.isEmpty()){ 
            isTimerRunning = true;	Xhist.add( 1, 419 );
            undeliveredPackageTimer.schedule(new TimerTask() { 
                @Override 
                public void run() { 
                    //check if there are any undelivered packages 
                    if(!undeliveredPeerUpdateMessages.isEmpty()){ 
                        byte[] message = createPeerUpdatePayloadFromUser(user);	Xhist.add( 1, 425 );
                        for(Map.Entry<Integer,MeshId> meshIdEntry: undeliveredPeerUpdateMessages.entrySet()){ 
                            MeshId peerId = meshIdEntry.getValue();
                            try { 
                                //send the packages again if there are undelivered packages 
                                meshManager.sendDataReliable(peerId, MESH_PORT, message);	Xhist.add( 1, 430 );
                            } catch (RightMeshException e) { 
                                e.printStackTrace();	Xhist.add( 1, 432 );
                            } 
                        } 
                        // All undelivered messages were sent again so Map is empty now. 
                        undeliveredPeerUpdateMessages.clear();	Xhist.add( 1, 436 );
 
                    } 
                    // so that another schedule task runs if it needs to 
                    isTimerRunning = false;	Xhist.add( 1, 440 );
                } 
            },UNDELIVERED_PACKAGE_TIMEOUT); 
        } 
    } 
}