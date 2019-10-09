#!/bin/bash
echo "#########################################"
echo  "Copyright (c) 2019 solomonqta"
echo  "Email: phper_wx@163.com"
echo  "Create: 2019.10.09"
echo  "Github: https://github.com/solomonqta"
echo "#######################################"
#批量修改文件名（随机英文组合）


#单词词典文件所在路径（必须绝对路径，否则获取时位置不对）
filepath="/Users/solomonqta/Desktop/tool/FileReplace/words.txt"
#单词词典文件中总共有多少个单词
totalWordsNum=`wc -l $filepath | awk '{print $1}'`
#指定一个文件夹
ROOTFOLDER=$1
if [ ! -d $ROOTFOLDER ] || [ ! $ROOTFOLDER ]; then
    echo "文件夹不存在"
    exit
fi

#获取一个随机数
function rand()
{
    min=$1
    max=$(($2-$min+1))
    num=$(($RANDOM+1000000000)) #增加一个10位的数再求余
    echo $(($num%$max+$min))
}

#获取一个文件名
function get_file_name()
{
    idx=1
    #NUM为要生成的随机单词的个数
    NUM=$(rand 1 5)
    declare -i num
    declare -i randNum
    ratio=37

    while [ "$idx" -le "$NUM" ]
    do
        a=$RANDOM
        num=$(( $a*$ratio ))
        randNum=`expr $num%$totalWordsNum`
        fName=$(sed -n "$randNum"p $filepath)
        first=`echo ${fName}|cut -c -1| sed "y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/"`
        fName2=${first}`echo ${fName}|cut -c 2-`
        funName=${funName}${fName2}

        idx=`expr $idx + 1`
    done

    echo ${funName}

}

#读取文件做修改
function read_file() {
    echo "===DIR---> $1"
    
    ls|
    while read line
    do

        if test -d "${line}"
        then
            cd ${line}
            read_file ${line}
            cd ..
        else
    
            echo "old name:$line"
            
            #获取后缀
            v1="."${line##*.}
#            echo "v1="$v1
            
            #过滤非文件
            if [ -z `echo $v1|sed 's/\./ /'` ]; then
                echo "continue file.$line"
                continue
            fi

            #重命名文件名
            v2=$(get_file_name)
#            echo "v2="$v2

            #写内容进入文件改变md5
            echo $v2 >> "$line"
            
            #修改文件名
            mv "$line" $v2$v1
            echo "new name:"$v2$v1
    
        fi
    
    done
    
}
 
#查路径，是否有文件夹
function set_dir() {
    if test -d $1
    then
        cd $1
        read_file
        cd ..
    else
        read_file $1
    fi
}

#备份
echo "备份打包文件${ROOTFOLDER}"
zip -rq `echo $ROOTFOLDER|sed "s/\/$//"`".zip" $ROOTFOLDER
echo "备份完成"

echo "修改文件名开始"
set_dir $ROOTFOLDER
echo "修改文件名结束"


