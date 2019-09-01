#!/bin/bash

#保存先
path="/home/pi/Videos/DriveRecorder/"

#保存するファイル数の上限
maxFilesNum=30

#録画時間 10分
RecordingTime=600000

#一時保存ファイル名
h264Video="video.h264"

#ログファイルの上限 10MB
maxFileSize=10485760
#ログファイルのバイト数
logFileSize=`ls -l ${path}drive_recorder.log | awk '{print $5}'`
#ログの容量が大きければ削除する
if [ ${logFileSize} -gt ${maxFileSize} ]
then
    rm ${path}drive_recorder.log
    echo "[DELETE LOG FILE]" >> "${path}drive_recorder.log" 2>&1
fi

echo "start!" >> "${path}drive_recorder.log" 2>&1

#前回の録画途中のファイルがあればmp4化する
if [ -e ${path}${h264Video} ]
then
    echo "[LAST RECORDING]" >> "${path}drive_recorder.log" 2>&1
   
    #保存するmp4のファイル名
    lastRecordingDate=`date +%Y%m%d%H%M%S -r ${path}${h264Video}`
    #mp4化
    MP4Box -add ${path}${h264Video} ${path}${lastRecordingDate}.mp4 >> "${path}drive_recorder.log" 2>&1
    #ファイルがない場合
    if [ ! -e ${path}${recordingDate}.mp4 ]
    then
        echo "[ERROR]${path}${lastRecordingDate}.mp4 undifined" >> "${path}drive_recorder.log" 2>&1
        exit 1
    fi
    #一時ファイル削除
    rm ${path}${h264Video}
fi

#ループはじめ
while :
do

echo "[START of tern]" >> "${path}drive_recorder.log" 2>&1

#path下のファイル数
totalNumberOfFiles=`ls -U1 ${path} | wc -l`

echo "[TOTAL NUMBER OF FILES]${totalNumberOfFiles}" >> "${path}drive_recorder.log" 2>&1

#指定したファイル数の上限を超えていたら古いファイルから削除する
if [ ${totalNumberOfFiles} -gt ${maxFilesNum} ]
then 
    oldestFile=`ls /home/pi/Videos/DriveRecorder/ -tr | head -1`
    rm ${path}${oldestFile}
fi

#保存するmp4のファイル名
recordingDate=`date "+%Y%m%d%H%M%S"`
#録画
raspivid -o ${path}${h264Video} -t ${RecordingTime} >> "${path}drive_recorder.log" 2>&1
#ファイルがない場合
if [ ! -e ${path}${h264Video} ]
then
    echo "[ERROR]${path}${h264Video} undifined" >> "${path}drive_recorder.log" 2>&1
    exit 1
fi
#mp4化
MP4Box -add ${path}${h264Video} ${path}${recordingDate}.mp4 >> "${path}drive_recorder.log" 2>&1
#ファイルがない場合
if [ ! -e ${path}${recordingDate}.mp4 ]
then
    echo "[ERROR]${path}${recordingDate}.mp4 undifined" >> "${path}drive_recorder.log" 2>&1
    exit 1
fi
#一時ファイル削除
rm ${path}${h264Video}

echo "[END of tern]" >> "${path}drive_recorder.log" 2>&1

#ループ終わり
done

echo "end!" >> "${path}drive_recorder.log" 2>&1