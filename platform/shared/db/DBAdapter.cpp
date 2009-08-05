#include "DBAdapter.h"

#include "common/RhoFile.h"
#include "common/RhoFilePath.h"

extern "C" const char* RhoGetRootPath();
extern "C" const char* RhoGetRelativeBlobsPath();

namespace rho{
namespace db{
IMPLEMENT_LOGCLASS(CDBAdapter,"DB");

using namespace rho::common;

static int onDBBusy(void* data,int nTry)
{
    LOGC(ERROR,CDBAdapter::getLogCategory())+"Database BUSY";
    return 0;
}

void SyncBlob_DeleteCallback(sqlite3_context* dbContext, int nArgs, sqlite3_value** ppArgs)
{
    char* type = NULL;
    if ( nArgs < 2 )
        return;

    type = (char*)sqlite3_value_text(*(ppArgs+1));
    if ( type && strcmp(type,"blob.file") == 0 )
    {
        String strFilePath = RhoGetRootPath();
        strFilePath += "apps";
        strFilePath += (char*)sqlite3_value_text(*(ppArgs));
        CRhoFile::deleteFile(strFilePath.c_str());
    }
}

/*static*/ String CDBAdapter::makeBlobFolderName()
{
    String strBlobPath = RhoGetRootPath();
    return strBlobPath + RhoGetRelativeBlobsPath();
}

boolean CDBAdapter::checkDbError(int rc)
{
    if ( rc == SQLITE_OK || rc == SQLITE_ROW || rc == SQLITE_DONE )
        return true;

    const char * szErrMsg = sqlite3_errmsg(m_dbHandle);
    int nErrCode = sqlite3_errcode(m_dbHandle);

    LOG(ERROR)+"DB query failed. Error code: " + nErrCode + ";Message: " + szErrMsg;

    return false;
}

void CDBAdapter::open (String strDbPath, String strVer)
{
    if ( strcasecmp(strDbPath.c_str(),m_strDbPath.c_str() ) == 0 )
        return;
    close();

    m_strDbPath = strDbPath;
    m_strDbVer = strVer;

    checkVersion(strVer);

    boolean bExist = CRhoFile::isFileExist(strDbPath.c_str());
    int nRes = sqlite3_open(strDbPath.c_str(),&m_dbHandle);
    if ( !checkDbError(nRes) )
        return;
    //TODO: raise exception if error
    if ( !bExist )
        createSchema();

    sqlite3_create_function( m_dbHandle, "rhoOnDeleteObjectRecord", 3, SQLITE_ANY, 0,
	    SyncBlob_DeleteCallback, 0, 0 );
    sqlite3_busy_handler(m_dbHandle, onDBBusy, 0 );
}

sqlite3_stmt* CDBAdapter::createInsertStatement(rho::db::CDBResult& res, const String& tableName, CDBAdapter& db, String& strInsert)
{
    sqlite3_stmt* stInsert = 0;
    int nColCount = sqlite3_data_count(res.getStatement());

  	if ( strInsert.length() == 0 )
    {
	    strInsert = "INSERT INTO ";
	
	    strInsert += tableName;
	    strInsert += "(";
	    String strQuest = ") VALUES(";
        String strValues = "";
	    for (int nCol = 0; nCol < nColCount; nCol++ )
	    {
            String strColName = sqlite3_column_name(res.getStatement(),nCol);
            if ( strColName == "id")
                continue;

		    if ( strValues.length() > 0 )
		    {
			    strValues += ",";
			    strQuest += ",";
		    }
    		
		    strValues += strColName; 
		    strQuest += "?";
	    }
    	
	    strInsert += strValues + strQuest + ")";
    }

    int rc = sqlite3_prepare_v2(db.getDbHandle(), strInsert.c_str(), -1, &stInsert, NULL);
    if ( !checkDbError(rc) )
    	return 0;
    
	for (int nCol = 0; nCol < nColCount; nCol++ )
	{
		int nColType = sqlite3_column_type(res.getStatement(),nCol);
        String strColName = sqlite3_column_name(res.getStatement(),nCol);
        if ( strColName == "id")
            continue;

		switch(nColType){
			case SQLITE_NULL:
                sqlite3_bind_text(stInsert, nCol, null, -1, SQLITE_TRANSIENT);
                break;
            case SQLITE_INTEGER:
            {
                sqlite_int64 nValue = sqlite3_column_int64(res.getStatement(), nCol);
                sqlite3_bind_int64(stInsert, nCol, nValue);
                break;
            }
			default:{
                char* szValue = (char *)sqlite3_column_text(res.getStatement(), nCol);
                sqlite3_bind_text(stInsert, nCol, szValue, -1, SQLITE_TRANSIENT);
				break;
			}
		}
    }

	return stInsert;
}

void CDBAdapter::destroy_table(String& strTable)
{
    CFilePath oFilePath(m_strDbPath);
	String dbNewName  = oFilePath.changeBaseName("resetdbtemp.sqlite");

    CRhoFile::deleteFile(dbNewName.c_str());
    CRhoFile::deleteFile((dbNewName+"-journal").c_str());

    CDBAdapter db;
    db.open( dbNewName, m_strDbVer );

    //Copy all tables

    Vector<String> vecTables;
    DBResult( res , executeSQL( "SELECT name FROM sqlite_master WHERE type='table' " ) );
    for ( ; !res.isEnd(); res.next() )
        vecTables.addElement(res.getStringByIdx(0));

    db.startTransaction();
    for ( int i = 0; i < (int)vecTables.size(); i++ )
    {
        String tableName = vecTables.elementAt(i);
        if ( tableName.compare(strTable)==0 )
            continue;

        String strSelect = "SELECT * from " + tableName;
        DBResult( res , executeSQL( strSelect.c_str() ) );
		String strInsert = "";
        int rc = 0;
	    for ( ; !res.isEnd(); res.next() )
	    {
	    	sqlite3_stmt* stInsert = createInsertStatement(res, tableName, db, strInsert);

            if (stInsert)
            {
                rc = sqlite3_step(stInsert);
                checkDbError(rc);
                sqlite3_finalize(stInsert);
            }
	    }
    }

    db.endTransaction();
    db.close();

    String dbOldName = m_strDbPath;
    close();
    CRhoFile::deleteFile(dbOldName.c_str());
    CRhoFile::renameFile(dbNewName.c_str(),dbOldName.c_str());
    open( dbOldName, m_strDbVer );
}

void CDBAdapter::checkVersion(String& strVer)
{
    //TODO: checkVersion
}

static const char* g_szDbSchema = 
    "CREATE TABLE client_info ("
    " client_id VARCHAR(255) PRIMARY KEY,"
    " token VARCHAR(255) default NULL,"
    " token_sent int default 0,"
    " reset int default 0,"
    " port VARCHAR(10) default NULL,"
    " last_sync_success VARCHAR(100) default NULL);"
    "CREATE TABLE object_values ("
    " id INTEGER PRIMARY KEY,"
    " token INTEGER default NULL,"
    " source_id int default NULL,"
    " attrib varchar(255) default NULL,"
    " object varchar(255) default NULL,"
    " value text default NULL,"
    " update_type varchar(255) default NULL,"
    " attrib_type varchar(255) default NULL);"
    "CREATE TABLE sources ("
    " id INTEGER PRIMARY KEY,"
    " token INTEGER default NULL,"
    " source_id int default -1,"
    " source_url VARCHAR(255) default NULL,"
    " name VARCHAR(255) default NULL,"
    " session VARCHAR(255) default NULL,"
    " last_updated int default 0,"
    " last_inserted_size int default 0,"
    " last_deleted_size int default 0,"
    " last_sync_duration int default 0,"
    " last_sync_success int default 0);"
    "CREATE INDEX by_attrib_utype on object_values (attrib,update_type);"
    "CREATE INDEX by_src_type ON object_values (source_id, attrib_type, object);"
    "CREATE INDEX by_src_utype on object_values (source_id,update_type);"
    "CREATE INDEX by_type ON object_values (attrib_type);"
    "CREATE TRIGGER rhodeleteTrigger BEFORE DELETE ON object_values FOR EACH ROW "
        "BEGIN "
            "SELECT rhoOnDeleteObjectRecord(OLD.value,OLD.attrib_type,OLD.update_type);"
        "END;"
    ";";

void CDBAdapter::createSchema()
{
    char* errmsg = 0;
    int rc = sqlite3_exec(m_dbHandle, g_szDbSchema,  NULL, NULL, &errmsg);

    if ( rc != SQLITE_OK )
        LOG(ERROR)+"createSchema failed. Error code: " + rc + ";Message: " + (errmsg ? errmsg : "");

    if ( errmsg )
        sqlite3_free(errmsg);
}

void CDBAdapter::close()
{
    for (Hashtable<String,sqlite3_stmt*>::iterator it = m_mapStatements.begin();  it != m_mapStatements.end(); ++it )
        sqlite3_finalize( it->second );

    m_mapStatements.clear();

    if ( m_dbHandle != 0 )
        sqlite3_close(m_dbHandle);

    m_dbHandle = 0;
    m_strDbPath = String();
}

DBResultPtr CDBAdapter::prepareStatement( const char* szSt )
{
    if ( m_dbHandle == null )
        return new CDBResult(m_mxDB);

	DBResultPtr res = new CDBResult(0,m_bInsideTransaction ? m_mxTransDB : m_mxDB);
    sqlite3_stmt* st = m_mapStatements.get(szSt);
    if ( st != null )
	{
		res->setStatement(st);
        return res;
	}
	
    int rc = sqlite3_prepare_v2(m_dbHandle, szSt, -1, &st, NULL);
    if ( !checkDbError(rc) )
    {
        //TODO: raise exception
        return res;
    }

    res->setStatement(st);
    m_mapStatements.put(szSt, st);

    return res;
}

DBResultPtr CDBAdapter::executeSQL( const char* szSt)
{
    DBResultPtr res = prepareStatement(szSt);
    if ( res->getStatement() == null )
        return res;

    return executeStatement(res);
}

DBResultPtr CDBAdapter::executeStatement(DBResultPtr& res)
{
    int rc = sqlite3_step(res->getStatement());
    if ( rc != SQLITE_ROW )
    {
        res->setStatement(null);
        if ( rc != SQLITE_OK && rc != SQLITE_ROW && rc != SQLITE_DONE )
        {
            checkDbError(rc);
            //TODO: raise exception
            return res;
        }
    }

    return res;
}

void CDBAdapter::startTransaction()
{
    Lock();
	m_bInsideTransaction=true;
    char *zErr = 0;
    int rc = 0;
	if ( m_dbHandle )
    {
		rc = sqlite3_exec(m_dbHandle, "BEGIN IMMEDIATE;",0,0,&zErr);
        checkDbError(rc);
    }
}

void CDBAdapter::endTransaction()
{
    char *zErr = 0;
    int rc = 0;
	if (m_dbHandle)
    {
		rc = sqlite3_exec(m_dbHandle, "END;",0,0,&zErr);
        checkDbError(rc);
    }

	m_bInsideTransaction=false;
    Unlock();
}

void CDBAdapter::rollback()
{
    char *zErr = 0;
    int rc = 0;
	if (m_dbHandle)
    {
		rc = sqlite3_exec(m_dbHandle, "ROLLBACK;",0,0,&zErr);
        checkDbError(rc);
    }

	m_bInsideTransaction=false;
    Unlock();
}

}
}
