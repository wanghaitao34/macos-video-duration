#!/usr/bin/env python3
"""
生成 Automator Quick Action 工作流文件
自动处理 XML 特殊字符转义
"""
import plistlib
import os

SCRIPT = r"""#!/bin/bash

# 视频扩展名
VIDEO_EXT="mp4 mkv mov avi wmv flv webm m4v mpg mpeg ts mts m2ts 3gp rm rmvb vob ogv dv f4v asf divx hevc"

total_seconds=0
file_count=0
skip_count=0
declare -a all_videos

# 判断是否为视频文件
is_video() {
    local file="$1"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    for e in $VIDEO_EXT; do
        [ "$ext" = "$e" ] && return 0
    done
    return 1
}

# 收集视频文件（支持文件夹递归）
while IFS= read -r path; do
    [ -z "$path" ] && continue
    if [ -d "$path" ]; then
        while IFS= read -r -d '' f; do
            is_video "$f" && all_videos+=("$f")
        done < <(find "$path" -type f -not -name ".*" -print0 2>/dev/null)
    elif [ -f "$path" ]; then
        is_video "$path" && all_videos+=("$path")
    fi
done

total=${#all_videos[@]}
if [ $total -eq 0 ]; then
    osascript -e 'display dialog "未找到视频文件。\n\n支持格式：MP4、MKV、MOV、AVI、WMV 等" with title "视频时长统计" buttons {"确定"} default button 1 with icon caution'
    exit 0
fi

# 计算每个文件时长
for f in "${all_videos[@]}"; do
    dur=""
    # 优先使用 ffprobe
    if command -v ffprobe >/dev/null 2>&1; then
        dur=$(ffprobe -v error -show_entries format=duration \
            -of default=noprint_wrappers=1:nokey=1 "$f" 2>/dev/null | head -1)
    fi
    # 回退到 mdls
    if [ -z "$dur" ] || [ "$dur" = "N/A" ]; then
        dur=$(mdls -name kMDItemDurationSeconds -raw "$f" 2>/dev/null)
    fi
    # 验证是数字
    if echo "$dur" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
        total_seconds=$(echo "$total_seconds + $dur" | bc 2>/dev/null || echo "$total_seconds")
        ((file_count++))
    else
        ((skip_count++))
    fi
done

# 格式化时长
secs=${total_seconds%.*}
h=$((secs / 3600))
m=$(( (secs % 3600) / 60 ))
s=$((secs % 60))
formatted=$(printf "%02d:%02d:%02d" $h $m $s)

if [ $h -gt 0 ]; then
    friendly="${h} 小时 ${m} 分钟 ${s} 秒"
elif [ $m -gt 0 ]; then
    friendly="${m} 分钟 ${s} 秒"
else
    friendly="${s} 秒"
fi

msg="总时长: ${formatted}\n（${friendly}）\n\n共 ${file_count} 个视频文件"
[ $skip_count -gt 0 ] && msg="${msg}\n⚠️ ${skip_count} 个文件无法读取"

osascript -e "display dialog \"${msg}\" with title \"视频时长统计\" buttons {\"确定\"} default button 1 with icon note"
"""

workflow = {
    "AMApplicationBuild": "521.1",
    "AMApplicationVersion": "2.10",
    "AMDocumentVersion": "2",
    "actions": [
        {
            "action": {
                "AMAccepts": {
                    "Container": "List",
                    "Optional": False,
                    "Types": ["com.apple.cocoa.path"]
                },
                "AMActionVersion": "2.0.3",
                "AMApplication": ["Automator"],
                "AMParameterProperties": {
                    "COMMAND_STRING": {},
                    "CheckedForUserDefaultShell": {},
                    "inputMethod": {},
                    "shell": {},
                    "source": {}
                },
                "AMProvides": {
                    "Container": "List",
                    "Types": ["com.apple.cocoa.path"]
                },
                "ActionBundlePath": "/System/Library/Automator/Run Shell Script.action",
                "ActionName": "运行 Shell 脚本",
                "ActionParameters": {
                    "COMMAND_STRING": SCRIPT,
                    "CheckedForUserDefaultShell": True,
                    "inputMethod": 1,
                    "shell": "/bin/bash",
                    "source": ""
                },
                "BundleIdentifier": "com.apple.RunShellScript",
                "CFBundleVersion": "2.0.3",
                "CanShowSelectedItemsWhenRun": False,
                "CanShowWhenRun": True,
                "Category": ["AMCategoryUtilities"],
                "Class Name": "RunShellScriptAction",
                "InputUUID": "7A1E8A0D-19C9-4BCF-A42B-5D4A69F4E00B",
                "Keywords": ["Shell", "Script", "Command", "Run", "Unix"],
                "OutputUUID": "97A0EB18-FC2E-4B72-AF32-F7D90BC57F6C",
                "UUID": "C9CE5B3C-2E71-497F-B3FE-B44A7E37F77B",
                "UnlocalizedApplications": ["Automator"],
                "arguments": {},
                "conversionLabel": 0,
                "isViewVisible": True,
                "location": "309.5:244.0",
                "menuitemTitle": ""
            }
        }
    ],
    "connectors": {},
    "inputTypeIdentifier": "com.apple.Automator.fileSystemObject",
    "outputTypeIdentifier": "com.apple.Automator.nothing",
    "workflowMetaData": {
        "applicationBundleIDsByPath": {},
        "applicationPaths": [],
        "inputTypeIdentifier": "com.apple.Automator.fileSystemObject",
        "outputTypeIdentifier": "com.apple.Automator.nothing",
        "presentationMode": 15,  # Quick Action
        "processesInput": 0,
        "serviceApplicationBundleID": "com.apple.finder",
        "serviceApplicationPath": "/System/Library/CoreServices/Finder.app",
        "serviceInputTypeIdentifier": "com.apple.Automator.fileSystemObject",
        "serviceOutputTypeIdentifier": "com.apple.Automator.nothing",
        "serviceProcessesInput": 0,
        "useAutomaticInputType": False,
        "workflowTypeIdentifier": "com.apple.Automator.servicesMenu"
    }
}

output_path = os.path.join(
    os.path.dirname(__file__),
    "视频总时长.workflow", "Contents", "document.wflow"
)

with open(output_path, "wb") as f:
    plistlib.dump(workflow, f, fmt=plistlib.FMT_XML)

print(f"✅ 已生成: {output_path}")
