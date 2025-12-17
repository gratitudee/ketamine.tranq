local Flags = require("../modules/Flags")
local Glob = require("../modules/Flags")
-- Executor/Environment Functions
declare function getgenv(): { [string]: any }
declare function clonereference(object: Instance): Instance
declare function cloneref(object: Instance): Instance
declare function protectgui(gui: ScreenGui): nil
declare function gethui(): Instance
declare syn: {
    protect_gui: (gui: ScreenGui) -> nil
}
declare function setclipboard(text: string): ()
declare function clonefunction(func: (...any) -> ...any): (...any) -> ...any
declare function clonefunc(func: (...any) -> ...any): (...any) -> ...any
declare function copyfunction(func: (...any) -> ...any): (...any) -> ...any
declare function getcustomasset(path: string, noCache: boolean?): string
declare function readfile(path: string): string
declare function listfiles(path: string): {string}
declare function writefile(path: string, data: string): ()
declare function makefolder(path: string): ()
declare function appendfile(path: string, data: string): ()
declare function isfile(path: string): boolean
declare function isfolder(path: string): boolean
declare function delfile(path: string): ()
declare function delfolder(path: string): ()
declare function loadfile(path: string, chunkname: string?): ((...any) -> ...any?, string?)
declare function dofile(path: string): ()
declare function request(table: {Url: string, Method: string, Body: string?}): {Success: boolean, Body: string, StatusCode: number?, Headers: {[string]: string}?}
declare function SecureSpawn(func: (...any) -> ...any, a: any?, b: any?, c: any?, d: any?, e: any?): ()
declare function SecureCall(func: (...any) -> ...any, a: any?, b: any?, c: any?, d: any?, e: any?): (boolean, ...any)
declare function Import(ModulePath: string): any | nil
declare function DebugNotify(Message: string | {Title: string?, Description: string, Time: number?, SoundId: number?}): ()    

declare Drawing: {
    new: ((Type: "Line" | "Text" | "Image" | "Circle" | "Square" | "Triangle" | "Quad") -> any),
}

-- Entity Type Definitions
export type EntityObject = {
    -- Identity
    Key: string,
    Name: string,
    DisplayName: string,
    UserId: number?,
    
    -- Instances
    Character: Model,
    PrimaryPart: BasePart,
    Player: Player?,
    Humanoid: Humanoid?,
    HealthInstance: Instance?,
    
    -- State
    Position: Vector3,
    Velocity: Vector3,
    Health: number,
    MaxHealth: number,
    StaticHealth: number?,
    MaxHealthValue: number?,
    Team: string,
    TeamColor: Color3,
    Weapon: string?,
    
    -- Flags
    IsAlive: boolean,
    IsEnemy: boolean,
    IsVisible: boolean,
    IsWhitelisted: boolean,
    IsAimbotTarget: boolean,
    
    -- Body Parts
    Bones: {BasePart},
    AimParts: {[string]: {BasePart}},
    
    -- Rendering
    BoundingBox: {x: number, y: number, w: number, h: number}?,
    
    -- Internal
    Connections: {RBXScriptConnection},
    
    -- Methods
    GetBonePosition: (self: EntityObject, BoneName: string) -> Vector3?,
    GetBoneInstance: (self: EntityObject, BoneName: string) -> BasePart?,
    GetBoneSize: (self: EntityObject, BoneName: string) -> Vector3?,
    GetBoneRotation: (self: EntityObject, BoneName: string) -> {number}?,
    Update: (self: EntityObject) -> (),
    Destroy: (self: EntityObject) -> (),
}

export type EntityCallbacks = {
    Added: {(EntityObject) -> ()},
    Removed: {(EntityObject) -> ()},
    Hit: {(EntityObject, number) -> ()},
    Killed: {(EntityObject) -> ()},
}

export type Entity = {
    Entities: {[string]: EntityObject},
    Callbacks: EntityCallbacks,
    PlayerConnections: {[Player]: {RBXScriptConnection}},
    GlobalConnections: {RBXScriptConnection},
    
    AddModel: (self: Entity, Key: string, Data: {
        Name: string,
        DisplayName: string?,
        Character: Model,
        PrimaryPart: BasePart,
        Player: Player?,
        Humanoid: Humanoid?,
        HealthInstance: Instance?,
        Health: number?,
        MaxHealth: number?,
        Team: string?,
        TeamColor: Color3?,
        Weapon: string?,
    }) -> boolean,
    
    RemoveModel: (self: Entity, Key: string) -> boolean,
    ClearModels: (self: Entity) -> boolean,
    EditModel: (self: Entity, Key: string, Data: {
        Health: number?,
        MaxHealth: number?,
        Team: string?,
        TeamColor: Color3?,
        Weapon: string?,
    }) -> boolean,
    
    GetLocalPlayer: (self: Entity) -> EntityObject?,
    GetPlayers: (self: Entity, OnlyEnemies: boolean?) -> {EntityObject},
    
    OnEntityAdded: (self: Entity, Callback: (EntityObject) -> ()) -> (),
    OnEntityRemoved: (self: Entity, Callback: (EntityObject) -> ()) -> (),
    OnEntityHit: (self: Entity, Callback: (EntityObject, number) -> ()) -> (),
    OnEntityKilled: (self: Entity, Callback: (EntityObject) -> ()) -> (),
    
    Load: (self: Entity) -> (),
    Unload: (self: Entity) -> (),
}

export type Cheat = {
    UnloadCallbacks: {() -> ()},
    Connections: {RBXScriptConnection?},
    
    WorldToScreen: (self: Cheat, WorldPosition: Vector3) -> (Vector3, boolean),
    Connect: (self: Cheat, ConnectionType: RBXScriptSignal, Function: (...any) -> ()) -> number?,
    Disconnect: (self: Cheat, ConnectionIndex: number) -> (),
    OnUnload: (self: Cheat, Callback: () -> ()) -> (),
    Load: (self: Cheat) -> (),
    Unload: (self: Cheat) -> (),
}

export type Draw = {
    Load: (self: Draw) -> (),
    Unload: (self: Draw) -> (),
    [string]: any,
}

export type Ketamine = {
    Print: (self: Ketamine, ...any) -> (),
    Notify: (self: Ketamine, options: {
        Title: string?,
        Description: string,
        Time: number?,
        SoundId: number?,
    }) -> (),
    SecureCall: (self: Ketamine, Function: (...any) -> ...any, ...any) -> (boolean, ...any),
    SecureSpawn: (self: Ketamine, Function: (...any) -> ...any, ...any) -> (),
    Import: (self: Ketamine, Path: string) -> any?,
    [string]: any,
}

-- Global Declarations
declare Ketamine: Ketamine
declare Entity: Entity
declare Cheat: Cheat
declare Draw: Draw