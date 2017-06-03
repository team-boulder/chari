//
//  FyberPlugin.mm
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FyberPlugin.h"

#include "CoronaRuntime.h"

#import <UIKit/UIKit.h>

#import "FyberSDK.h"
#import "FyberPluginImpl.h"


// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char FyberPlugin::kName[] = "plugin.fyber";

// This corresponds to the event name, e.g. [Lua] event.name
const char FyberPlugin::kEvent[] = "FyberPluginEvent";

const char FyberPlugin::kValueRewardVideoDidReceived[] = "DidReceivedVideo";
const char FyberPlugin::kValueRewardVideoDidFailedToReceive[] = "DidFailedToReceiveVideo";
const char FyberPlugin::kValueRewardVideoDismiss[] = "DismissVideo";
const char FyberPlugin::kValueRewardVideoDidStart[] = "DidStartVideo";
const char FyberPlugin::kValueRewardVideoFailedToStart[] = "FailedToStartVideo";
const char FyberPlugin::kValueVirtualCurrencyReceived[] = "ReceivedVirtualCurrency";
const char FyberPlugin::kValueVirtualCurrencyFailedToReceive[] = "FailedToReceiveVirtualCurrency";



FyberPlugin::FyberPlugin()
:	fListener( NULL ), fPluginImpl(nil)
{
}

int
FyberPlugin::Open( lua_State *L )
{
	// Register __gc callback
	const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
	CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );

	// Functions in library
	const luaL_Reg kVTable[] =
	{
		{ "init", init },
        { "requestRewardedVideo", requestRewardedVideo },
        { "playRewardedVideo", playRewardedVideo },

		{ NULL, NULL }
	};

	// Set library as upvalue for each library function
	Self *library = new Self;
	CoronaLuaPushUserdata( L, library, kMetatableName );

	luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack

	return 1;
}

int
FyberPlugin::Finalizer( lua_State *L )
{
    Self *library = (Self *)CoronaLuaToUserdata( L,  1 );

    if (library->fListener != nil) {
        CoronaLuaDeleteRef( L, library->fListener );
    }
	delete library;

	return 0;
}

FyberPlugin *
FyberPlugin::ToLibrary( lua_State *L )
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	return library;
}

// [Lua] library.init( "appId", "securityToken", listener )
int
FyberPlugin::init( lua_State *L )
{
    const char* appIdStr = luaL_checkstring(L, 1);
    const char* securityTokenStr = luaL_checkstring(L, 2);

    Self *library = ToLibrary( L );

    int listenerIndex = 3;
    CoronaLuaRef listener = nil;
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )  {
        if (  library->fListener != NULL)  {
            CoronaLuaDeleteRef(L, library->fListener);
        }
        library->fListener = CoronaLuaNewRef( L, listenerIndex );
    } else {
        NSLog(@"FyberPlugin::init() Must give a listener");
        return 0;
    }

    if (appIdStr != NULL && securityTokenStr != NULL) {
        Self *library = ToLibrary( L );
        if (library->fPluginImpl != nil) {
            [library->fPluginImpl release];
            library->fPluginImpl = nil;
        }
        NSString* appId = [NSString stringWithCString:appIdStr encoding:NSUTF8StringEncoding];
        NSString* securityToken = [NSString stringWithCString:securityTokenStr encoding:NSUTF8StringEncoding];
        id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );
        library->fPluginImpl =[[FyberPluginImpl alloc] initWithLibrary: library runtime:runtime appId:appId securityToken:securityToken];
    } else {
        NSLog(@"FyberPlugin::init() Invalid argument");
    }

	return 0;
}


// [Lua] library.requestRewardedVideo( )
int
FyberPlugin::requestRewardedVideo( lua_State *L )
{
    // check for init has been done before
    Self *library = ToLibrary( L );
    if (library->fPluginImpl == nil) {
        NSLog(@"FyberPlugin::requestRewardedVideo Initialize with FyberPlugin.init() is necessary");
        return 0;
    }
    // request the offers
    [library->fPluginImpl requestVideo];
    
    return 0;
}

// [Lua] library.playRewardedVideo(  )
int
FyberPlugin::playRewardedVideo( lua_State *L )
{
    // check for init has been done before
    Self *library = ToLibrary( L );
    if (library->fPluginImpl == nil) {
        NSLog(@"FyberPlugin::playRewardedVideo Initialize with FyberPlugin.init() is necessary");
        return 0;
    }
    
    // request the offers
    [library->fPluginImpl playVideo];

    return 0;
}

void
FyberPlugin::sendEventGeneric(lua_State* L, const char* value, const char* reason, const char* currencyName, float deltaOfCurrency)
{
    // Create event and add message to it
    CoronaLuaNewEvent( L, FyberPlugin::kEvent );
    lua_pushstring( L, value);
    lua_setfield( L, -2, "message");
    if (reason != NULL) {
        lua_pushstring( L, reason);
        lua_setfield( L, -2, "reason");
    }
    if (currencyName != NULL) {
        lua_pushstring( L, currencyName);
        lua_setfield( L, -2, "currencyName");
        lua_pushnumber(L, deltaOfCurrency);
        lua_setfield( L, -2, "deltaOfCurrency");
    }
    
    // Dispatch event to library's listener
    CoronaLuaDispatchEvent( L, fListener, 0 );
    
}

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_fyber( lua_State *L )
{
	return FyberPlugin::Open( L );
}
