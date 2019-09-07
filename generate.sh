#!/usr/bin/env bash
# 服务组名称(包名第一段)
ONE='com'
# 服务名称(包名第二段)
TWO='sixi'
# 服务组名称(包名第三段)
GROUP='pay'
# 服务名称(包名第四段)
SERVER='base'
# 指定对应文件生成目录(如果不是微服务项目 请自行修改完整包名)
TARGET_ENTITY="${ONE}.${TWO}.${GROUP}.${SERVER}.domain.entity"
TARGET_MAPPER="${ONE}.${TWO}.${GROUP}.${SERVER}.mapper"
# 数据库地址
DB_HOST="dev.mysql.i.sixi.com"
# 数据库端口
DB_PORT=3306
# 数据库名称
DB_NAME="sixipay_platform"
# 数据库用户名
DB_USER="root"
# 数据库密码
DB_PASS="root"
# 表名 多个表用空格分隔 所有的表用 % 代替
TABLES='%'
###############################
# 请勿修改以下部分代码 除非你看得懂 #
###############################
# 链接字符串
CONNECTION_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false"
# 代码生成根目录
TARGET_ROOT=target/mybatis-generator/${SERVER}
TARGET_JAVA="${TARGET_ROOT}/java"
TARGET_RESOURCES="${TARGET_ROOT}/resources"
# 删除已有代码
rm -rf target/mybatis-generator/${SERVER}
# 新建目录
mkdir -p ${TARGET_ROOT}/java
mkdir -p ${TARGET_ROOT}/resources
# 初始化表XML字符串
TABLE_XML=''
for TABLE in ${TABLES}; do
    # 新增表 默认添加INSERT返回主键
    TABLE_XML="${TABLE_XML}<table tableName=\"${TABLE}\" delimitIdentifiers=\"true\"><generatedKey column=\"id\" sqlStatement=\"JDBC\"/></table>"
done
# 写入XML文件
cat > generator.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
        PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>
    <context id="info" targetRuntime="MyBatis3">
        <property name="javaFileEncoding" value="UTF-8"/>
        <property name="autoDelimitKeywords" value="true"/>
        <property name="beginningDelimiter" value="\`"/>
        <property name="endingDelimiter" value="\`"/>
        <!--启用Lombok插件-->
        <plugin type="zcf.mybatis.generator.plugins.LombokPlugin"/>
        <commentGenerator>
            <!--去除自动生成的注释-->
            <property name="suppressAllComments" value="true"/>
        </commentGenerator>
        <jdbcConnection driverClass="com.mysql.jdbc.Driver"
                        connectionURL="${CONNECTION_URL}"
                        userId="${DB_USER}"
                        password="${DB_PASS}">
        </jdbcConnection>
        <javaTypeResolver>
            <!-- 设置 DECIMAL 和 NUMERIC 类型解析为 java.math.BigDecimal -->
            <property name="forceBigDecimals" value="true"/>
        </javaTypeResolver>
        <javaModelGenerator targetPackage="${TARGET_ENTITY}"
                            targetProject="${TARGET_JAVA}">
            <property name="enableSubPackages" value="false"/>
            <property name="trimStrings" value="true"/>
        </javaModelGenerator>
        <sqlMapGenerator targetPackage="${TARGET_MAPPER}"
                         targetProject="${TARGET_RESOURCES}">
            <property name="enableSubPackages" value="false"/>
        </sqlMapGenerator>
        <javaClientGenerator type="XMLMAPPER"
                             targetPackage="${TARGET_MAPPER}"
                             targetProject="${TARGET_JAVA}">
            <property name="enableSubPackages" value="false"/>
        </javaClientGenerator>
        ${TABLE_XML}
    </context>
</generatorConfiguration>
EOF
# 执行Maven构建
mvn mybatis-generator:generate