SQLCL_URI=$JDBC_HOSTNAME:$JDBC_PORT/$JDBC_SERVICE_NAME
JDBC_URI=jdbc:oracle:thin:@//$SQLCL_URI

xmlstarlet ed --inplace -u "/Configure/New/Arg/New/Set[@name='URL']" -v ${JDBC_URI} $OSA_HOME/osa-base/etc/jetty-osa-datasource.xml
xmlstarlet ed --inplace -u "/Configure/New/Arg/New/Set[@name='User']" -v ${JDBC_USERNAME} $OSA_HOME/osa-base/etc/jetty-osa-datasource.xml
xmlstarlet ed --inplace -u "/Configure/New/Arg/New/Set[@name='Password']" -v ${JDBC_PASSWORD} $OSA_HOME/osa-base/etc/jetty-osa-datasource.xml


$INSTALL_DIR/sqlcl/bin/sql $JDBC_DBA_USERNAME/$JDBC_DBA_PASSWORD@$SQLCL_URI @$INSTALL_DIR/create_user.sql $JDBC_USERNAME $JDBC_PASSWORD $OSA_USERNAME $OSA_PASSWORD

cd $OSA_HOME/osa-base
bin/configure-osa.sh osaadmin_password=$OSA_PASSWORD

$OSA_HOME/osa-base/bin/start-osa.sh
sleep 10
tail -f $OSA_HOME/osa-base/logs/`date '+%Y_%m_%d'`.jetty.log

$INSTALL_DIR/sqlcl/bin/sql $JDBC_DBA_USERNAME/$JDBC_DBA_PASSWORD@$SQLCL_URI @$INSTALL_DIR/create_osa_user.sql $JDBC_USERNAME $JDBC_PASSWORD 


