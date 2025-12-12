declare function getgenv(): { [string]: any }
declare function clonereference(object: Instance): Instance
declare function cloneref(object: Instance): Instance
declare function protectgui(gui: ScreenGui): nil
declare function gethui(): Instance
declare syn: {
    protect_gui: (gui: ScreenGui) -> nil
}
declare Ketamine: {
    Loaded: boolean,
    StealthMode: boolean,
    Interface: {

    },
    Modules: {

    },
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
declare function request(table: {Url: string, Method: string}): (string)
declare function SecureSpawn(func: (...any) -> ...any, a: any?, b: any?, c: any?, d: any?, e: any?): ()
declare function SecureCall(func: (...any) -> ...any, a: any?, b: any?, c: any?, d: any?, e: any?): (boolean, ...any)
declare function Import(ModulePath: string): any | nil
declare function DebugNotify(Message: string | {Title: string?, Description: string, Time: number?, SoundId: number?}): ()    

declare Drawing: {
    new: ((Type: "Line" | "Text" | "Image" | "Circle" | "Square" | "Triangle" | "Quad") -> any),
}