#pragma once

#include "HttpServer.h"
#include "syncengine/rsyncengine.h"

class CServerHost
{
public:
  CServerHost(void);
  virtual ~CServerHost(void);

  bool Start();
  void Stop ();

private:
    CHttpServer m_httpserver;
    CSyncEngine m_syncengine;
};
