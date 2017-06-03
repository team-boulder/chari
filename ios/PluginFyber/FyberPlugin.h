//
//  FyberPlugin.h
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef _FyberPlugin_H__
#define _FyberPlugin_H__

#include "CoronaLua.h"
#include "CoronaMacros.h"

// This corresponds to the name of the library, e.g. [Lua] require "plugin.fyber"
// where the '.' is replaced with '_'
CORONA_EXPORT int luaopen_plugin_fyber( lua_State *L );

// ----------------------------------------------------------------------------

@class FyberPluginImpl;

class FyberPlugin
{
public:
    typedef FyberPlugin Self;
    
public:
    static const char kName[];
    static const char kEvent[];
    static const char kKeyRewardVideo[];
    static const char kValueRewardVideoDidReceived[];
    static const char kValueRewardVideoDidFailedToReceive[];
    static const char kKeyRewardVideoErrorReason[];
    static const char kValueRewardVideoDismiss[];
    static const char kValueRewardVideoDidStart[];
    static const char kValueRewardVideoFailedToStart[];
    static const char kValueVirtualCurrencyReceived[];
    static const char kValueVirtualCurrencyFailedToReceive[];

protected:
    FyberPlugin();
    
public:
    void    sendEventGeneric(lua_State* L, const char* value, const char* reason = NULL, const char* currencyName = NULL, float deltaOfCurrency = 0.0f);
    
public:
    CoronaLuaRef GetListener() const { return fListener; }
    
public:
    static int Open( lua_State *L );
    
protected:
    static int Finalizer( lua_State *L );
    
public:
    static Self *ToLibrary( lua_State *L );
public:
    static int init( lua_State *L );
    static int requestRewardedVideo( lua_State *L );
    static int playRewardedVideo( lua_State *L );
    
private:
    CoronaLuaRef fListener;
    FyberPluginImpl* fPluginImpl;
};


#endif // _FyberPlugin_H__
