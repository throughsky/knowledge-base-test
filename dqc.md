# dqc使用指南

# **1、**dqc功能

**为保证数据质量，对hive表进行数据校验工作，其中主要包括：****表内一致性校验、表间关联性校验、数据量校验、主键校验**等，并将数据校验结果写入hive表和断批告警操作

**dqc分为在线和离线使用，使用重点区别在于是否直接指定本地校验文件来校验数据，如果为在线，则不需要指定本地校验文件，但需要每次将改动和新建的校验文件上传到dqc平台；如果为离线使用，则需要指定本地校验文件，因此省略了在线dqc的xml文件上传步骤，但需要在dqc的配置文件中加入配置，明确说明使用离线功能。**

# **2、**dqc在线使用

**指dqc相关校验规则上传到dqc平台使用，不需要指定项目中的校验文件**

## **2.1、**xml文件上传

### **2.1.1、**上传命令

**使用 DQC 平台时，必须通过以下操作确保文件同步：**

1. **上传触发条件**

**新增的 cmn或ind XML 文件**

**已存在但内容被修改的 cmn或ind 文件**

2. **命令格式**

**在 aomp 发版流程中加入执行命令** **（**  **发布模板已包含该命令，可跳过此步骤** **）**

```
案例：
sh  -x /data/bdp/bdp_etl_deploy/hduser1040/rrs_east5_bdp/etl_submit.sh --type=dqcUpload --batch_date=${batch_date} --dqcPath=/data/bdp/bdp_etl_deploy/hduser1040/rrs_east5_hive/dqc/  --VERSION=${VERSION_NO}


解释：
etl_submit.sh  --blanca使用脚本
batch_date  --跑批日期
dqcPath  --dqc文件夹目录
VERSION  --发布版本
```

**关键组件说明**

**执行脚本：etl_submit.sh（Blanca 调度系统专用脚本）**

**dqcPath：DQC 文件统一存储目录**

**VERSION：与版本目录名保持一致的动态版本号**

### **2.1.2、**上传方式

**在 dqcPath 路径下执行以下操作：**

1. **文件分类存放**
   1. **若为**** cmn 类型** XML 文件（表内校验文件），放入 dqc 目录
   2. **若为**** ind 类型 **XML 文件（表间校验文件），放入 indicator 目录
2. **创建版本目录**

**新建以****当前版本号**命名的文件夹（例如 25.11.1）

3. **记录变更文件**

**在版本文件夹中**

**创建 dqc.txt，写入本次变动的 cmn 文件名**

**创建 indicator.txt，写入本次变动的 ind 文件名**

**示例：**

**版本 25.11.1 中修改/新建了 RRS_EAST_DGCKFHZ.xml（cmn）和 EASTR_3_BJGLL_GLJY_2676.xml（ind）时：**

**dqc.txt 内容：RRS_EAST_DGCKFHZ.xml**

**indicator.txt 内容：EASTR_3_BJGLL_GLJY_2676.xml **

```
dqcPath/
├── dqc/                   # 存放所有 cmn 类型 XML 文件
│   └── RRS_EAST_DGCKFHZ.xml      # 示例文件（本次新增/修改）
│
├── indicator/             # 存放所有 ind 类型 XML 文件
│   └── EASTR_3_BJGLL_GLJY_2676.xml  # 示例文件（本次新增/修改）
│
└── 25.11.1/               # 当前版本目录
    ├── dqc.txt            # 记录本次 cmn 文件：RRS_EAST_DGCKFHZ.xml
    └── indicator.txt      # 记录本次 ind 文件：EASTR_3_BJGLL_GLJY_2676.xml
```

**关键说明**

**文件存放规则：通过文件名后缀 cmn/ind 或内容类型自动区分目录**

**版本记录：每个版本的变动文件独立记录在对应版本文件夹的 .txt 中**

**文件内容格式：.txt 文件每行仅记录一个文件名（含 .xml 后缀）**

2. ## 2、**dqc的conf配置文件（已配置可忽略）**

**在项目conf文件夹下任意文件加入****校验结果表名称**

```
案例：
在conf目录下的spark.properties文件中加入
check.table.name="rrs_east_cmn_check_result"
check.result.table.name="rrs_east_check_result_statistic"
ind.rule.result.table.name="rrs_east_ind_rule_check_result"


解释：
check.table.name：cmn表内数据校验明细表配置
check.result.table.name：cmn表内数据校验统计表配置
ind.rule.result.table.name：ind表间数据校验配置（同时会自动生成一份后缀带有_detail的ind明细表）
```

1. **创建****dqc_cmn.conf**文件（表内检验，主键，数据量配置文件）

```
案例：
  dqc_common {
    dqc_type="${dqc_type}" // dqc,dqc_pk,dqc_nodata
    tablename="${tablename}"
    where="ds='${batch_date}'"
    dqc_pk_ignore="true"
    dqc_nodata_ignore="true" 
    tableschema="imd_east_dm_safe"
  }
  
解释：
dqc_type：dqc校验类型，具体分为表内cmn校验(dqc)，表主键校验(dqc_pk)，表数据量校验(dqc_nodata)
tablename：校验表名
where：校验范围，一般过滤当天日期分区
dqc_pk_ignore：如果为主键校验，冲突后是否忽略不报错
dqc_nodata_ignore：如果为数据量校验，数据量为0后是否忽略不报错
tableschema：如果不配置tableschema，默认就是当前库
```

1. **创建****dqc_ind.conf**文件（表间校验配置文件）

```
dqc{
  dqc_ind {
   ind="${ind_list}"
 }
}


解释：
ind：ind指标编码名称
```

## **2.3、**四种主要使用方式

### **a. 表内数据校验(cmn)**

**通过上传xml文件内容，dqc_cmn.conf配置文件及表数据内容进行校验**

#### **xml内容**

**主要包括表结构（库名，表中文名，表英文名，字段中文名，字段英文名，字段格式）、是否为主键，是否可以为空，及表内字段规则名和其**Aviator表达式校验

**主要标签介绍**

**tableName：表英文名**

**tableSchema：库名**

**tableNameCn：表中文名**

**enabledCheck：是否校验**

**belongSystemCode：所属子系统编码**

**columnOrder：字段序号**

**columnName：字段英文名**

**columnType：字段类型**

**isPk：是否为主键**

**columnNameCn：字段中文名**

**isNullable：是否可以为空**

**dataFormat：金融字段格式**

**enabledCheck：是否校验**

**alarmLevel：校验级别**

**columnRules：规则列表，用于写规则表达式**

**ruleName：规则名称**

**ruleType：规则类型**

**columnRule：校验表达式**

```
案例：
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<tableInfos>
<tableInfo tableComment="" charset="" tableType="" sourceTable="" sourceTableDb="" filterCondition="">
    <tableName>RRS_EAST_GYB</tableName>
    <tableSchema>IMD_EAST_DM_SAFE</tableSchema>
    <tableNameCn>柜员表</tableNameCn>
    <enabledCheck>Y</enabledCheck>
    <lengthCheckType>byte</lengthCheckType>
    <belongSystemCode>EAST5.0</belongSystemCode>
    <columnInfos>
        <columnInfo columnComment="" isFixedLength="N" length="0" numericPrecision="0" numericScale="0" columnDefault="">
            <columnOrder>5</columnOrder>
            <columnName>GH</columnName>
            <columnType>VARCHAR(30)</columnType>
            <isPk>Y</isPk>
            <columnNameCn>工号</columnNameCn>
            <isNullable>N</isNullable>
            <dataFormat>C..30</dataFormat>
            <enabledCheck>Y</enabledCheck>
            <alarmLevel>仅告警</alarmLevel>
            <columnRules>
                <columnRule ruleParams="row.SFSTGY=='是'?str.isNotBlank(row.GH)&&string.byteLength(row.GH)!=0:true" preCondition="" ruleDependency="" ruleDesc="是否实体柜员“是”时,工号不允许为空">
                    <ruleName>EASTR_1_QSL_WKJY_0030</ruleName>
                    <ruleType>AviatorExpression</ruleType>
                    <isDependency>N</isDependency>
                    <checkLevel>仅告警</checkLevel>
                    <enabledCheck>Y</enabledCheck>
                    <createdUser></createdUser>
                    <updateUser></updateUser>
                </columnRule>
            </columnRules>
            <createdUser></createdUser>
            <updateUser></updateUser>
        </columnInfo>
    </columnInfos>
    <partCol></partCol>
    <extraCols>prodcd</extraCols>
    <createdUser>admin_EAST5</createdUser>
    <updateUser>admin_EAST5</updateUser>
    <createDate>2022-04-12T23:53:11+08:00</createDate>
    <updateDate>2022-11-04T21:24:59+08:00</updateDate>
    </tableInfo>
</tableInfos>
```

#### **wtss调用命令**

```
案例：
sh ./etl_submit.sh --type=blanca --conf=bin/common/blanca_config/dqc_cmn.conf --freq=day --tablename=rrs_east_xdhtb --batch_date=${run_date_std} --dqc_type=dqc


解释：
etl_submit.sh  --blanca使用脚本
batch_date  --跑批日期
freq   --跑批频率，day每天，month月末
tablename：校验表名，dqc平台可以通过表名映射到对应的cmn的xml文件
dqc_type：调用方式为dqc
conf：cmn的dqc的配置文件
```

### **b. 表间数据校验(ind)**

 **通过上传ind的xml文件内容，** **dqc_ind.conf配置文件及多张表数据内容****进行校验（当表内校验** **Aviator表达式无法满足复杂的校验内容时，也可以使用ind的sql方式校验** **）**

#### **xml内容**

**xml内容主要包括ind指标名称，及对应的校验sql(** **需要拼接主键写入区分唯一数据** **，例如**concat('KHTYBH=',a.khtybh,'|','CJRQ=',a.cjrq,'|') as key_columns**)**

**主要标签介绍**

**belongSystemCode：所属子系统**

**selfCode：指标名称**

**secondIndCode：频率**

**formulaInstance：校验sql**

```
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<indicators>
    <indicator indDesc="对公客户信息表法人信息（证件号码）在个人基础信息表不存在">
        <belongSystemCode>EAST5.0</belongSystemCode>
        <firstIndCode>一般校验指标</firstIndCode>
        <selfCode>EASTW_00009</selfCode>
        <indName>GLJY-FRDBZJHM_ZJHM_EAST5</indName>
        <secondIndCode>每日</secondIndCode>
        <subCodes></subCodes>
        <formulaInstance formulaDesc="对公客户表法人信息（证件号码）在个人基础信息表不存在">
            <formulaType>HIVE</formulaType>
            <formulaCont>
        select concat('KHTYBH=',a.khtybh,'|'
              ,'CJRQ=',a.cjrq,'|'
        ) as key_columns
          from rrs_east_dgkhxxb a
          left join rrs_east_grjcxxb b
          on a.frdbzjhm = b.zjhm and b.ds = '${batch_date}'
          where a.ds = '${batch_date}' and a.frdbzjhm is not null and b.zjhm is null;</formulaCont>
        </formulaInstance>
        <IndicatorRules>
            <IndicatorRule ruleDesc="对公客户表法人信息（证件号码）在个人基础信息表不存在">
                <ruleName>对公客户表法人信息（证件号码）在个人基础信息表不存在</ruleName>
                <ruleType>阈值命中</ruleType>
                <ruleContent>[{'max':'inf','min':'1','alertLevel':'5'}]</ruleContent>
                <staticParameter></staticParameter>
                <timeParameter></timeParameter>
            </IndicatorRule>
        </IndicatorRules>
        <outputDetailFlag>是</outputDetailFlag>
    </indicator>
</indicators>
```

#### **wtss调用命令**

```
案例：
sh etl_submit.sh --type=blanca --freq=${rule_243_freq} --batch_date=${run_date_std} --conf=bin/common/blanca_config/dqc_ind.conf --freq=day --ind_list=EAST5_VERIFY_DAILY_RULE_243_GRXDFHZMX_72


解释：
etl_submit.sh  --blanca使用脚本
batch_date  --跑批日期
freq   --跑批频率，day每天，month月末
ind_list：ind指标名称
conf：ind的dqc的配置文件
```

### **c. 主键校验**

**校验表数据在对应日期分区是否** **主键冲突** **（根据上传cmn的xml文件里面的字段是否为主键来进行校验）**

#### **wtss调用命令**

```
案例：
sh ./etl_submit.sh --type=blanca --conf=bin/common/blanca_config/dqc_cmn.conf --freq=day --tablename=rrs_east_xdhtb --batch_date=${run_date_std} --dqc_type=dqc_pk


解释：
etl_submit.sh  --blanca使用脚本
batch_date  --跑批日期
table_name：表名
freq   --跑批频率，day每天，month月末
dqc_type：指定是主键校验方式，dqc_pk
conf：cmn的dqc的配置文件
```

### **d. 数据量校验**

#### **wtss调用命令**

**校验表数据在对应日期分区是否****数据量为0**

```
案例：
sh ./etl_submit.sh --type=blanca --conf=bin/common/blanca_config/dqc_cmn.conf --freq=day --tablename=rrs_east_xdhtb --batch_date=${run_date_std} --dqc_type=dqc_nodata


解释：
etl_submit.sh  --blanca使用脚本
batch_date  --跑批日期
table_name：表名
freq   --跑批频率，day每天，month月末
dqc_type：指定是数据量校验方式，dqc_nodata
conf：cmn的dqc的配置文件
```

# **3、**dqc离线使用

### **conf配置文件**

**需要在dqc_cmn.conf或者dqc_ind.conf配置文件中加入****offline="true"，明确指定说明使用离线方式。**

```
案例：
  dqc_common {
    dqc_type="${dqc_type}" // dqc,dqc_pk,dqc_nodata
    tablename="${tablename}"
    where="ds='${batch_date}'"
    dqc_pk_ignore="true"
    dqc_nodata_ignore="true" 
    tableschema="imd_east_dm_safe"
    offline="true"
  }
```

### **a. 表内数据校验(cmn)**

```
sh etl_submit.sh --type=blanca --conf=bin/common/check/dqc_cmn.conf --tablename=ads_rods_org_info_df  --batch_date=${run_date_std}  --dqc_type=dqc  --dqc_file=bin/common/dqc/dqc_xml/t_1_1_ads_rods_org_info_df.xml


dqc_file:填写本地校验文件路径
其他与在线dqc使用方法一致
```

### **b. 表间数据校验(ind)**

```
sh etl_submit_stable.sh --type=blanca --conf=bin/common/check/dqc_ind.conf  --batch_date=${run_date_std} --ind_list=RODS_R_JYA02-03 --dqc_file=bin/common/dqc/ind_xml/RODS_R_JYA02-03.xml


dqc_file:填写本地校验文件路径
其他与在线dqc使用方法一致
```

### **c. 主键校验**

```
sh etl_submit_stable.sh --type=blanca --conf=bin/common/check/dqc_cmn.conf --tablename=ads_rods_org_info_df  --batch_date=${run_date_std}  --dqc_type=dqc_pk --dqc_file=bin/common/dqc/dqc_xml/t_1_1_ads_rods_org_info_df.xml


dqc_file:填写本地校验文件路径
其他与在线dqc使用方法一致
```

### **d. 数据量校验**

```
sh etl_submit_stable.sh --type=blanca --conf=bin/common/check/dqc_cmn.conf --tablename=ads_rods_org_info_df  --batch_date=${run_date_std}  --dqc_type=dqc_nodata --dqc_file=bin/common/dqc/dqc_xml/t_1_1_ads_rods_org_info_df.xml


dqc_file:填写本地校验文件路径
其他与在线dqc使用方法一致
```

# **4、cmn常用的规则类型和校验表达式**

### **4.1、规则类型**

```
ADDRESS 地址校验，仅校验地址是否是全是数字或字母
AviatorExpression 符合Aviator规范表达式, row为一行数据,col_value为字段数据
ConditionCheck 条件校验,如:if=[01,02],then=[{field}==null] 表示如果当前字段取值01或02,则字段field必须为null
D 日期格式校验,不需额外参数,判断是否为yyyy-MM-dd还是yyyyMMdd
DL 枚举值校验,参数:dataList=1,2,3表示只允许取值为1,2,3
DN 空值和零值校验,不需额外参数
DR 数据范围取值校验,参数:rangeData表示数据的比较范围,如[2,9],[1,9),[1,$FieldName];rangeTyep表示数据比较类型,支持日期date和数字bigdecimal
DREGEX 正则表达式校验,参数:regex=pattern, pattern为正则表达式
ENUM 支持分割字段值的枚举值校验，如字段A中的值为1;2;3,如需要对其分割成三个字符校验，可填参数：enumList=1,2,3;split=; 不需要分割校验去掉参数split即可
HqlCheck Hql语句片段校验,如:where length(a)<10 and datadt={DATA_DATE}表示取当前表日期为参数DATA_DATE的字段a小于10为校验不通过
ID 身份证号码校验,不需额外参数
LogicCheck 逻辑校验,如:{B}<{C}) && ({D[yyyyMMdd]}=={$current_date[yyyyMMdd]}) 表示当前规则为字段B小于字段C且字段D的日期值小于当前系统时间的日期值
LogicCondCheck 逻辑条件校验,如:if=[{a}==2],then=[check.checkDatetimeByPattern(‘{d}’,‘yyyyMMdd’)] 表示如果字段a为2,则字段d的格式需要满足时间格式yyyyMMdd,字符串类型变量需要加上单引号
MONEY_CK 金额数字范围校验,不需额外参数,表示float(17,2)的取值范围
NA 非空校验,不需额外参数2
PHONE 联系方式校验，仅校验联系方式既不是手机号也不是座机号
PHONE1 联系方式校验，仅校验联系方式既不是手机号也不是座机号
PHONE2 联系方式校验，仅校验联系方式既不是手机号也不是座机号
```

### **4.2、校验表达式**

```
isMatchRegex(Pattern pattern, CharSequence value) 通过正则模式验证字符串是否匹配
isNumber(CharSequence value) 验证字符串是否是数字
checkDatetimeByPattern(String checkStr, String pattern) 校验日期是否符合指定模板格式
isBlank(CharSequence str) 检查字符串是否为空白（null、空字符串或仅包含空白字符）
isNotBlank(CharSequence str) 检查字符串是否不为空白（非null、非空字符串且不全是空白字符）
containsAny(CharSequence str, CharSequence... testStrs) 检查字符串是否包含任意一个指定子串 
containsAny(CharSequence str, char... testChars) 检查字符串是否包含任意一个指定字符
split(CharSequence str, char separator) 按分隔符切分字符串为列表 
split(CharSequence str, CharSequence separator) 切分字符串，如果分隔符不存在则返回原字符串
sub(CharSequence str, int fromIndexInclude, int toIndexExclude) 改进JDK subString，支持负数索引
equalsAnyIgnoreCase(CharSequence str1, CharSequence... strs) 检查字符串是否与任一字符串相同（忽略大小写）
equalsAny(CharSequence str1, CharSequence... strs) 检查字符串是否与任一字符串相同 
length(CharSequence cs) 获取字符串长度（null返回0）
byteLength(CharSequence cs, Charset charset) 获取字符串转为bytes后的byte数
isTrue(boolean value) 对给定值判断是否是true
isFalse(boolean value) 对给定值判断是否是false
isNull(Object value) 判断给定值是否为null
isNotNull(Object value) 判断给定值是否不为null
isEmpty(Object value) 验证是否为空(对于String类型判断是否为null或"")
isNotEmpty(Object value) 验证是否为非空(对于String类型判断是否为null或"")
equal(Object t1, Object t2) 验证两个对象是否相等(都为null也返回true)
isMactchRegex(String regex, CharSequence value) 通过正则表达式验证字符串是否匹配
isGeneral(CharSequence value) 验证是否为英文字母、数字和下划线
isGeneral(CharSequence value, int min, int max) 验证是否为给定长度范围的英文字母、数字和下划线
isGeneral(CharSequence value, int min) 验证是否为给定最小长度的英文字母、数字和下划线
isLetter(CharSequence value) 判断字符串是否全部为字母组成(包括大小写字母和汉字)
isUpperCase(CharSequence value) 判断字符串是否全部为大写字母
isLowerCase(CharSequence value) 判断字符串是否全部为小写字母
isWord(CharSequence value) 验证字符串是否是字母(包括大小写字母)
isMoney(CharSequence value) 验证是否为货币格式
isZipCode(CharSequence value) 验证是否为邮政编码(中国)
isEmail(CharSequence value) 验证是否为可用邮箱地址
isMobile(CharSequence value) 验证是否为手机号码(中国)
isCitizenId(CharSequence value) 验证是否为身份证号码(18位中国)
isBirthday(int year, int month, int day) 验证是否为有效生日日期
isBirthday(CharSequence value) 验证字符串是否为生日格式(yyyyMMdd等格式)
isIpv4(CharSequence value) 验证是否为IPv4地址
isIpv6(CharSequence value) 验证是否为IPv6地址
isMac(CharSequence value) 验证是否为MAC地址
isPlateNumber(CharSequence value) 验证是否为中国车牌号
isUrl(CharSequence value) 验证是否为URL
isChinese(CharSequence value) 验证字符串是否全部为汉字
hasChinese(CharSequence value) 验证字符串是否包含汉字
isGeneralWithChinese(CharSequence value) 验证是否为中文字、英文字母、数字和下划线
isUUID(CharSequence value) 验证是否为UUID(带横线或不带横线)
isHex(CharSequence value) 验证是否为16进制字符串
isBetween(Number value, Number min, Number max) 检查数字是否在指定范围内
isCreditCode(CharSequence creditCode) 验证是否为有效的统一社会信用代码
withoutIllegalWords(CharSequence value) 验证是否不含非法词汇
isPhone(String value) 判断是否是座机号码
isNewMobile(String value) 判断是否是手机号码(支持大陆、香港、澳门、台湾)
isAllNumberOrChar(String value) 判断字符串是否全部为数字和字母
upperCase(String value) 将字符串转换为大写
lowerCase(String value) 将字符串转换为小写
isBlankIfStr(Object obj) 判断对象如果是字符串是否为空白(null/空字符串/空白字符)
isEmptyIfStr(Object obj) 判断对象如果是字符串是否为空(null/空字符串)
trim(String[] strs) 对字符串数组每个元素去除首尾空格
utf8Str(Object obj) 将对象转为UTF-8编码的字符串
str(Object obj, String charsetName) 将对象转为指定字符集的字符串(已废弃)
str(Object obj, Charset charset) 将对象转为指定字符集的字符串
str(byte[] bytes, String charset) 将byte数组转为指定字符集的字符串
str(byte[] data, Charset charset) 解码字节码为字符串
str(Byte[] bytes, String charset) 将Byte数组转为指定字符集的字符串
str(Byte[] data, Charset charset) 解码Byte数组为字符串
str(ByteBuffer data, String charset) 将ByteBuffer转为指定字符集的字符串
str(ByteBuffer data, Charset charset) 解码ByteBuffer为字符串
toString(Object obj) 调用对象的toString方法(null返回"null")
toStringOrNull(Object obj) 调用对象的toString方法(null返回null)
builder() 创建StringBuilder对象
strBuilder() 创建StrBuilder对象
builder(int capacity) 创建指定容量的StringBuilder对象
strBuilder(int capacity) 创建指定容量的StrBuilder对象
getReader(CharSequence str) 获得StringReader
getWriter() 获得StringWriter
reverse(String str) 反转字符串
fillBefore(String str, char filledChar, int len) 在字符串前填充字符到指定长度
fillAfter(String str, char filledChar, int len) 在字符串后填充字符到指定长度
fill(String str, char filledChar, int len, boolean isPre) 在字符串前后填充字符到指定长度
similar(String str1, String str2) 计算两个字符串的相似度
similar(String str1, String str2, int scale) 计算两个字符串的相似度百分比
uuid() 生成随机UUID
format(CharSequence template, Map<?, ?> map) 格式化文本(使用{varName}占位)
format(CharSequence template, Map<?, ?> map, boolean ignoreNull) 格式化文本(可控制是否忽略null值)
hasBlank(CharSequence... strs) 检查字符串数组中是否包含空白字符串
isAllBlank(CharSequence... strs) 检查字符串数组中的所有字符串是否都为空白
isEmpty(CharSequence str) 检查字符串是否为空（null或空字符串）
isNotEmpty(CharSequence str) 检查字符串是否不为空（非null且非空字符串）
emptyIfNull(CharSequence str) 如果字符串为null则返回空字符串
nullToEmpty(CharSequence str) 如果字符串为null则返回空字符串
nullToDefault(CharSequence str, String defaultStr) 如果字符串为null则返回默认值
emptyToDefault(CharSequence str, String defaultStr) 如果字符串为null或空则返回默认值
blankToDefault(CharSequence str, String defaultStr) 如果字符串为空白则返回默认值
emptyToNull(CharSequence str) 如果字符串为空则返回null
hasEmpty(CharSequence... strs) 检查字符串数组中是否包含空字符串
isAllEmpty(CharSequence... strs) 检查字符串数组中的所有字符串是否都为空
isAllNotEmpty(CharSequence... args) 检查字符串数组中的所有字符串是否都不为空
isAllNotBlank(CharSequence... args) 检查字符串数组中的所有字符串是否都不为空白
isNullOrUndefined(CharSequence str) 检查字符串是否为null、"null"或"undefined"
isEmptyOrUndefined(CharSequence str) 检查字符串是否为null、空、"null"或"undefined"
isBlankOrUndefined(CharSequence str) 检查字符串是否为空白、"null"或"undefined"
trim(CharSequence str) 去除字符串两端的空白字符
trimToEmpty(CharSequence str) 去除字符串两端的空白字符，如果为null则返回空字符串
trimToNull(CharSequence str) 去除字符串两端的空白字符，如果为空则返回null
trimStart(CharSequence str) 去除字符串开头的空白字符
trimEnd(CharSequence str) 去除字符串结尾的空白字符
startWith(CharSequence str, char c) 检查字符串是否以指定字符开头
startWith(CharSequence str, CharSequence prefix, boolean ignoreCase) 检查字符串是否以指定字符串开头（可忽略大小写）
startWith(CharSequence str, CharSequence prefix) 检查字符串是否以指定字符串开头
startWithIgnoreEquals(CharSequence str, CharSequence prefix) 检查字符串是否以指定字符串开头且不相等
startWithIgnoreCase(CharSequence str, CharSequence prefix) 检查字符串是否以指定字符串开头（忽略大小写）
startWithAny(CharSequence str, CharSequence... prefixes) 检查字符串是否以任意一个指定字符串开头
startWithAnyIgnoreCase(CharSequence str, CharSequence... suffixes) 检查字符串是否以任意一个指定字符串开头（忽略大小写）
endWith(CharSequence str, char c) 检查字符串是否以指定字符结尾
endWith(CharSequence str, CharSequence suffix, boolean ignoreCase) 检查字符串是否以指定字符串结尾（可忽略大小写）
endWith(CharSequence str, CharSequence suffix) 检查字符串是否以指定字符串结尾
endWithIgnoreCase(CharSequence str, CharSequence suffix) 检查字符串是否以指定字符串结尾（忽略大小写）
endWithAny(CharSequence str, CharSequence... suffixes) 检查字符串是否以任意一个指定字符串结尾
endWithAnyIgnoreCase(CharSequence str, CharSequence... suffixes) 检查字符串是否以任意一个指定字符串结尾（忽略大小写）
contains(CharSequence str, char searchChar) 检查字符串是否包含指定字符
contains(CharSequence str, CharSequence searchStr) 检查字符串是否包含指定子串
containsOnly(CharSequence str, char... testChars) 检查字符串是否只包含指定字符
containsAll(CharSequence str, CharSequence... testChars) 检查字符串是否包含所有指定子串
containsBlank(CharSequence str) 检查字符串是否包含空白字符
getContainsStr(CharSequence str, CharSequence... testStrs) 获取字符串中包含的第一个指定子串
containsIgnoreCase(CharSequence str, CharSequence testStr) 检查字符串是否包含指定子串（忽略大小写）
containsAnyIgnoreCase(CharSequence str, CharSequence... testStrs) 检查字符串是否包含任意一个指定子串（忽略大小写）
getContainsStrIgnoreCase(CharSequence str, CharSequence... testStrs) 获取字符串中包含的第一个指定子串（忽略大小写）
indexOf(CharSequence str, char searchChar) 查找字符在字符串中第一次出现的位置
indexOf(CharSequence str, char searchChar, int start) 从指定位置开始查找字符在字符串中第一次出现的位置
indexOf(CharSequence text, char searchChar, int start, int end) 在指定范围内查找字符在字符串中第一次出现的位置
indexOfIgnoreCase(CharSequence str, CharSequence searchStr) 查找子串在字符串中第一次出现的位置（忽略大小写）
indexOfIgnoreCase(CharSequence str, CharSequence searchStr, int fromIndex) 从指定位置开始查找子串在字符串中第一次出现的位置（忽略大小写）
indexOf(CharSequence text, CharSequence searchStr, int from, boolean ignoreCase) 在指定范围内查找子串在字符串中第一次出现的位置（可忽略大小写）
lastIndexOfIgnoreCase(CharSequence str, CharSequence searchStr) 查找子串在字符串中最后一次出现的位置（忽略大小写）
lastIndexOfIgnoreCase(CharSequence str, CharSequence searchStr, int fromIndex) 从指定位置开始查找子串在字符串中最后一次出现的位置（忽略大小写）
lastIndexOf(CharSequence text, CharSequence searchStr, int from, boolean ignoreCase) 在指定范围内查找子串在字符串中最后一次出现的位置（可忽略大小写）
ordinalIndexOf(CharSequence str, CharSequence searchStr, int ordinal) 查找子串在字符串中第ordinal次出现的位置
removeAll(CharSequence str, CharSequence strToRemove) 移除字符串中所有指定子串
removeAny(CharSequence str, CharSequence... strsToRemove) 移除字符串中所有指定子串（多个）
removeAll(CharSequence str, char... chars) 移除字符串中所有指定字符
removeAllLineBreaks(CharSequence str) 移除字符串中所有换行符
removePreAndLowerFirst(CharSequence str, int preLength) 去掉字符串前preLength个字符并将剩余部分首字母小写
removePreAndLowerFirst(CharSequence str, CharSequence prefix) 去掉字符串指定前缀并将剩余部分首字母小写
removePrefix(CharSequence str, CharSequence prefix) 去掉字符串指定前缀
removePrefixIgnoreCase(CharSequence str, CharSequence prefix) 去掉字符串指定前缀（忽略大小写）
removeSuffix(CharSequence str, CharSequence suffix) 去掉字符串指定后缀
removeSufAndLowerFirst(CharSequence str, CharSequence suffix) 去掉字符串指定后缀并将剩余部分首字母小写
removeSuffixIgnoreCase(CharSequence str, CharSequence suffix) 去掉字符串指定后缀（忽略大小写）
cleanBlank(CharSequence str) 清理字符串中的空白字符
strip(CharSequence str, CharSequence prefixOrSuffix) 去除字符串两边的指定字符串
strip(CharSequence str, CharSequence prefix, CharSequence suffix) 去除字符串两边的指定前缀和后缀
stripIgnoreCase(CharSequence str, CharSequence prefixOrSuffix) 去除字符串两边的指定字符串（忽略大小写）
stripIgnoreCase(CharSequence str, CharSequence prefix, CharSequence suffix) 去除字符串两边的指定前缀和后缀（忽略大小写）
addPrefixIfNot(CharSequence str, CharSequence prefix) 如果字符串不以prefix开头则在开头添加prefix
addSuffixIfNot(CharSequence str, CharSequence suffix) 如果字符串不以suffix结尾则在结尾添加suffix
splitToLong(CharSequence str, char separator) 按分隔符切分字符串为long数组
splitToLong(CharSequence str, CharSequence separator) 按分隔符切分字符串为long数组
splitToInt(CharSequence str, char separator) 按分隔符切分字符串为int数组
splitToInt(CharSequence str, CharSequence separator) 按分隔符切分字符串为int数组
splitToArray(CharSequence str, CharSequence separator) 按分隔符切分字符串为数组
splitToArray(CharSequence str, char separator) 按分隔符切分字符串为数组
splitToArray(CharSequence text, char separator, int limit) 按分隔符切分字符串为数组（限制分片数）
split(CharSequence str, char separator, int limit) 按分隔符切分字符串为列表（限制分片数）
splitTrim(CharSequence str, char separator) 按分隔符切分字符串并去除空白项
splitTrim(CharSequence str, CharSequence separator) 按分隔符切分字符串并去除空白项
splitTrim(CharSequence str, char separator, int limit) 按分隔符切分字符串并去除空白项（限制分片数）
splitTrim(CharSequence str, CharSequence separator, int limit) 按分隔符切分字符串并去除空白项（限制分片数）
split(CharSequence str, char separator, boolean isTrim, boolean ignoreEmpty) 切分字符串，不限制分片数量，可去除空格和忽略空串
split(CharSequence str, char separator, int limit, boolean isTrim, boolean ignoreEmpty) 切分字符串，限制分片数，可去除空格和忽略空串
split(CharSequence str, char separator, int limit, boolean ignoreEmpty, Function<String, R> mapping) 切分字符串并转换元素类型，限制分片数，可忽略空串
split(CharSequence str, CharSequence separator, boolean isTrim, boolean ignoreEmpty) 切分字符串，不限制分片数，可去除空格和忽略空串
split(CharSequence str, CharSequence separator, int limit, boolean isTrim, boolean ignoreEmpty) 切分字符串，限制分片数，可去除空格和忽略空串
split(CharSequence str, int len) 根据给定长度将字符串截取为多个部分
cut(CharSequence str, int partLength) 将字符串切分为N等份
subByCodePoint(CharSequence str, int fromIndex, int toIndex) 通过CodePoint截取字符串，可以截断Emoji
subPreGbk(CharSequence str, int len, CharSequence suffix) 截取部分字符串(GBK编码)，一个汉字长度认为是2
subPreGbk(CharSequence str, int len, boolean halfUp) 截取部分字符串(GBK编码)，可控制是否保留半个字符
subPre(CharSequence string, int toIndexExclude) 切割指定位置之前部分的字符串
subSuf(CharSequence string, int fromIndex) 切割指定位置之后部分的字符串
subSufByLength(CharSequence string, int length) 切割指定长度的后部分的字符串
subWithLength(String input, int fromIndex, int length) 截取字符串，从指定位置开始截取指定长度
subBefore(CharSequence string, CharSequence separator, boolean isLastSeparator) 截取分隔字符串之前的字符串
subBefore(CharSequence string, char separator, boolean isLastSeparator) 截取分隔字符之前的字符串
subAfter(CharSequence string, CharSequence separator, boolean isLastSeparator) 截取分隔字符串之后的字符串
subAfter(CharSequence string, char separator, boolean isLastSeparator) 截取分隔字符之后的字符串
subBetween(CharSequence str, CharSequence before, CharSequence after) 截取两个字符串中间部分
subBetween(CharSequence str, CharSequence beforeAndAfter) 截取成对字符串中间部分
subBetweenAll(CharSequence str, CharSequence prefix, CharSequence suffix) 截取多段两个字符串中间部分
subBetweenAll(CharSequence str, CharSequence prefixAndSuffix) 截取多段成对字符串中间部分
repeat(char c, int count) 重复某个字符指定次数
repeat(CharSequence str, int count) 重复某个字符串指定次数
repeatByLength(CharSequence str, int padLen) 重复字符串到指定长度
repeatAndJoin(CharSequence str, int count, CharSequence delimiter) 重复字符串并通过分界符连接
equals(CharSequence str1, CharSequence str2) 比较两个字符串（大小写敏感）
equalsIgnoreCase(CharSequence str1, CharSequence str2) 比较两个字符串（大小写不敏感）
equals(CharSequence str1, CharSequence str2, boolean ignoreCase) 比较两个字符串，可指定是否忽略大小写
equalsAny(CharSequence str1, boolean ignoreCase, CharSequence... strs) 检查字符串是否与任一字符串相同，可指定是否忽略大小写
equalsCharAt(CharSequence str, int position, char c) 检查字符串指定位置的字符是否与给定字符相同
isSubEquals(CharSequence str1, int start1, CharSequence str2, boolean ignoreCase) 比较子串是否相同
isSubEquals(CharSequence str1, int start1, CharSequence str2, int start2, int length, boolean ignoreCase) 比较两个字符串的不同部分是否相同
format(CharSequence template, Object... params) 格式化文本，使用{}作为占位符
indexedFormat(CharSequence pattern, Object... arguments) 有序格式化文本，使用{number}作为占位符
utf8Bytes(CharSequence str) 编码字符串为UTF-8字节数组
bytes(CharSequence str) 编码字符串为系统默认编码字节数组
bytes(CharSequence str, String charset) 编码字符串为指定编码字节数组
bytes(CharSequence str, Charset charset) 编码字符串为指定字符集字节数组
byteBuffer(CharSequence str, String charset) 字符串转换为byteBuffer
wrap(CharSequence str, CharSequence prefixAndSuffix) 包装字符串，前后缀相同
wrap(CharSequence str, CharSequence prefix, CharSequence suffix) 包装字符串
wrapAllWithPair(CharSequence prefixAndSuffix, CharSequence... strs) 使用单个字符包装多个字符串
wrapAll(CharSequence prefix, CharSequence suffix, CharSequence... strs) 包装多个字符串
wrapIfMissing(CharSequence str, CharSequence prefix, CharSequence suffix) 包装字符串，如果前缀或后缀不存在
wrapAllWithPairIfMissing(CharSequence prefixAndSuffix, CharSequence... strs) 使用成对字符包装多个字符串，如果不存在
wrapAllIfMissing(CharSequence prefix, CharSequence suffix, CharSequence... strs) 包装多个字符串，如果不存在
unWrap(CharSequence str, String prefix, String suffix) 去掉字符包装
unWrap(CharSequence str, char prefix, char suffix) 去掉字符包装
unWrap(CharSequence str, char prefixAndSuffix) 去掉成对字符包装
isWrap(CharSequence str, String prefix, String suffix) 检查字符串是否被包装
isWrap(CharSequence str, String wrapper) 检查字符串是否被同一字符串包装
isWrap(CharSequence str, char wrapper) 检查字符串是否被同一字符包装
isWrap(CharSequence str, char prefixChar, char suffixChar) 检查字符串是否被指定字符包装
padPre(CharSequence str, int length, CharSequence padStr) 前补充字符串以满足长度
padPre(CharSequence str, int length, char padChar) 前补充字符以满足长度
padAfter(CharSequence str, int length, char padChar) 后补充字符以满足长度
padAfter(CharSequence str, int length, CharSequence padStr) 后补充字符串以满足长度
center(CharSequence str, final int size) 居中字符串，两边补充空格
center(CharSequence str, final int size, char padChar) 居中字符串，两边补充指定字符
center(CharSequence str, final int size, CharSequence padStr) 居中字符串，两边补充指定字符串
str(CharSequence cs) CharSequence转为字符串，null安全
count(CharSequence content, CharSequence strForSearch) 统计指定内容中包含指定字符串的数量
count(CharSequence content, char charForSearch) 统计指定内容中包含指定字符的数量
compare(final CharSequence str1, final CharSequence str2, final boolean nullIsLess) 比较两个字符串用于排序
compareIgnoreCase(CharSequence str1, CharSequence str2, boolean nullIsLess) 比较两个字符串用于排序，忽略大小写
compareVersion(CharSequence version1, CharSequence version2) 比较两个版本号
appendIfMissing(CharSequence str, CharSequence suffix, CharSequence... suffixes) 如果字符串不以给定字符串结尾则添加
appendIfMissingIgnoreCase(CharSequence str, CharSequence suffix, CharSequence... suffixes) 如果字符串不以给定字符串结尾则添加，忽略大小写
appendIfMissing(CharSequence str, CharSequence suffix, boolean ignoreCase, CharSequence... testSuffixes) 如果字符串不以给定字符串结尾则添加，可指定是否忽略大小写
prependIfMissing(CharSequence str, CharSequence prefix, CharSequence... prefixes) 如果字符串不以给定前缀开头，则在首部添加前缀（不忽略大小写）
prependIfMissingIgnoreCase(CharSequence str, CharSequence prefix, CharSequence... prefixes) 如果字符串不以给定前缀开头，则在首部添加前缀（忽略大小写）
prependIfMissing(CharSequence str, CharSequence prefix, boolean ignoreCase, CharSequence... prefixes) 如果字符串不以给定前缀开头，则在首部添加前缀（可指定是否忽略大小写）
replaceIgnoreCase(CharSequence str, CharSequence searchStr, CharSequence replacement) 替换字符串中的指定字符串（忽略大小写）
replace(CharSequence str, CharSequence searchStr, CharSequence replacement) 替换字符串中的指定字符串
replace(CharSequence str, CharSequence searchStr, CharSequence replacement, boolean ignoreCase) 替换字符串中的指定字符串（可指定是否忽略大小写）
replace(CharSequence str, int fromIndex, CharSequence searchStr, CharSequence replacement, boolean ignoreCase) 从指定位置开始替换字符串中的指定字符串（可指定是否忽略大小写）
replace(CharSequence str, int startInclude, int endExclude, char replacedChar) 替换字符串指定区间内的字符为固定字符
replace(CharSequence str, int startInclude, int endExclude, CharSequence replacedStr) 替换字符串指定区间内的字符为指定字符串
replace(CharSequence str, java.util.regex.Pattern pattern, Func1<java.util.regex.Matcher, String> replaceFun) 使用正则匹配并自定义函数替换文本
replace(CharSequence str, String regex, Func1<java.util.regex.Matcher, String> replaceFun) 使用正则表达式匹配并自定义函数替换文本
replaceLast(CharSequence str, CharSequence searchStr, CharSequence replacedStr) 替换字符串中最后一个匹配的子串
replaceLast(CharSequence str, CharSequence searchStr, CharSequence replacedStr, boolean ignoreCase) 替换字符串中最后一个匹配的子串（可指定是否忽略大小写）
replaceFirst(CharSequence str, CharSequence searchStr, CharSequence replacedStr) 替换字符串中第一个匹配的子串
replaceFirst(CharSequence str, CharSequence searchStr, CharSequence replacedStr, boolean ignoreCase) 替换字符串中第一个匹配的子串（可指定是否忽略大小写）
hide(CharSequence str, int startInclude, int endExclude) 将字符串指定区间内的字符替换为'*'（脱敏功能）
desensitized(CharSequence str, DesensitizedUtil.DesensitizedType desensitizedType) 使用指定脱敏策略对字符串脱敏
replaceChars(CharSequence str, String chars, CharSequence replacedStr) 替换字符串中所有在指定字符列表中的字符
replaceChars(CharSequence str, char[] chars, CharSequence replacedStr) 替换字符串中所有在指定字符数组中的字符
totalLength(CharSequence... strs) 计算多个字符串的总长度
maxLength(CharSequence string, int length) 限制字符串最大长度，超出部分用"..."表示
firstNonNull(T... strs) 返回第一个非null元素
firstNonEmpty(T... strs) 返回第一个非空字符串元素
firstNonBlank(T... strs) 返回第一个非空白字符串元素
upperFirstAndAddPre(CharSequence str, String preString) 首字母大写并在首部添加指定字符串
upperFirst(CharSequence str) 将字符串首字母大写
lowerFirst(CharSequence str) 将字符串首字母小写
filter(CharSequence str, Filter<Character> filter) 使用过滤器过滤字符串中的字符
isUpperCase(CharSequence str) 判断字符串是否全部为大写字母
isLowerCase(CharSequence str) 判断字符串是否全部为小写字母
swapCase(String str) 切换字符串中的大小写（大写转小写，小写转大写）
toUnderlineCase(CharSequence str) 将驼峰式命名转换为下划线命名
toSymbolCase(CharSequence str, char symbol) 将驼峰式命名转换为指定符号连接命名
toCamelCase(CharSequence name) 将下划线命名转换为驼峰式命名
toCamelCase(CharSequence name, char symbol) 将指定符号连接的命名转换为驼峰式命名
isSurround(CharSequence str, CharSequence prefix, CharSequence suffix) 判断字符串是否被指定前后缀包围
isSurround(CharSequence str, char prefix, char suffix) 判断字符串是否被指定前后字符包围
builder(CharSequence... strs) 创建StringBuilder并追加初始字符串
strBuilder(CharSequence... strs) 创建StrBuilder并追加初始字符串
getGeneralField(CharSequence getOrSetMethodName) 从get/set/is方法名中获取属性名
genSetter(CharSequence fieldName) 根据属性名生成set方法名
genGetter(CharSequence fieldName) 根据属性名生成get方法名
concat(boolean isNullToEmpty, CharSequence... strs) 连接多个字符串为一个
brief(CharSequence str, int maxLength) 将字符串截短为指定最大长度并用"..."表示
join(CharSequence conjunction, Object... objs) 以指定分隔符连接多个对象
join(CharSequence conjunction, Iterable<T> iterable) 以指定分隔符连接集合元素
isAllCharMatch(CharSequence value, Matcher<Character> matcher) 判断字符串所有字符是否都匹配指定条件
isNumeric(CharSequence str) 判断字符串是否全部由数字组成
move(CharSequence str, int startInclude, int endExclude, int moveLength) 循环位移字符串指定区间的字符
isCharEquals(CharSequence str) 判断字符串所有字符是否相同
normalize(CharSequence str) 对字符串进行Unicode规范化处理
fixLength(CharSequence str, char fixedChar, int length) 在字符串末尾填充指定字符到指定长度
hasLetter(CharSequence str) 判断字符串是否包含字母
commonPrefix(CharSequence str1, CharSequence str2) 获取两个字符串的公共前缀
commonSuffix(CharSequence str1, CharSequence str2) 获取两个字符串的公共后缀
```
