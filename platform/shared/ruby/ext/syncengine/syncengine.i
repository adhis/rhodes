/* syncengine.i */
%module SyncEngine
%{
/* Put header files here or function declarations like below */
	extern void rho_sync_doSyncAllSources(int show_status_popup);
	#define dosync_source rho_sync_doSyncSource
	extern void rho_sync_doSyncSource(VALUE source_id,int show_status_popup);
	#define dosearch_source rho_sync_doSearchSource
	extern void rho_sync_doSearchSource(int source_id, const char *from, const char *params, int sync_changes, int nProgressStep, const char* callback, const char* callback_params);
	#define dosync rho_sync_doSyncAllSources
	extern void rho_sync_lock();
	#define lock_sync_mutex rho_sync_lock
	extern void rho_sync_unlock();
	#define unlock_sync_mutex rho_sync_unlock
	extern void rho_sync_login(const char *login, const char *password, const char* callback);
	#define login rho_sync_login
	extern int rho_sync_logged_in();
	#define logged_in rho_sync_logged_in
	extern void rho_sync_logout();
	#define logout rho_sync_logout
	extern void rho_sync_stop();
	#define stop_sync rho_sync_stop
	extern void rho_sync_set_notification(int source_id, const char *url, char* params);
	#define set_notification rho_sync_set_notification
	extern void rho_sync_clear_notification(int source_id);
	#define clear_notification rho_sync_clear_notification
	extern void rho_sync_set_pollinterval(int interval);
	#define set_pollinterval rho_sync_set_pollinterval
	extern void rho_sync_set_syncserver(char* syncserver);
	#define set_syncserver rho_sync_set_syncserver
	extern VALUE rho_sync_get_attrs(int source_id);
	#define get_src_attrs rho_sync_get_attrs
	
    extern void  rho_sync_setobjectnotify_url(const char* szUrl);
    #define set_objectnotify_url rho_sync_setobjectnotify_url
    extern void  rho_sync_addobjectnotify(int nSrcID, const char* szObject);
    #define add_objectnotify rho_sync_addobjectnotify
    extern void  rho_sync_cleanobjectnotify();
    #define clean_objectnotify rho_sync_cleanobjectnotify

    extern int  rho_sync_get_lastsync_objectcount(int nSrcID);
    #define get_lastsync_objectcount rho_sync_get_lastsync_objectcount

    extern int  rho_sync_get_pagesize();
    #define get_pagesize rho_sync_get_pagesize

    extern void  rho_sync_set_pagesize(int pagesize);
    #define set_pagesize rho_sync_set_pagesize

	extern void rho_sync_set_initial_notification(const char *url, char* params);
	#define set_initial_notification rho_sync_set_initial_notification
	extern void rho_sync_clear_initial_notification();
	#define clear_initial_notification rho_sync_clear_initial_notification
	
	#if !defined(bool)
	#define bool int
	#define true  1
	#define false 0
	#endif
%}

%typemap(default) bool show_status_popup {
 $1 = 1;
}
extern void dosync(bool show_status_popup);
extern void dosync_source(VALUE source_id, bool show_status_popup);
extern void dosearch_source(int source_id, const char *from, const char *params, bool sync_changes, int nProgressStep, const char* callback, const char* callback_params);
extern void lock_sync_mutex();
extern void unlock_sync_mutex();
extern void login(const char *login, const char *password, const char* callback);
extern int logged_in();
extern void logout();
extern void stop_sync();
extern void set_notification(int source_id, const char *url, char* params);
extern void clear_notification(int source_id);
extern void set_pollinterval(int interval);
extern void set_syncserver(char* syncserver);
extern VALUE get_src_attrs(int source_id);
extern void  set_objectnotify_url(const char* szUrl);
extern void  add_objectnotify(int nSrcID, const char* szObject);
extern void  clean_objectnotify();
extern int   get_lastsync_objectcount(int nSrcID);
extern int   get_pagesize();
extern void  set_pagesize(int pagesize);
extern void  set_initial_notification(const char *url, char* params);
extern void  clear_initial_notification();

