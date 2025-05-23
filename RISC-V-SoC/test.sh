#!/bin/bash

# 提示用户输入仓库根目录
echo "Please enter the path to your repository:"
read repo_dir

# 检查用户输入的路径是否存在且是目录
if [ ! -d "$repo_dir" ]; then
    echo "Error: The directory $repo_dir does not exist or is not a directory."
    exit 1
fi



# 请求用户输入备份目录的基础路径
read -p "请输入备份目录的基础路径（例如：/path/to/your/backup_repo）: " base_backup_dir

# 获取当前日期和时间作为备份目录的一部分名称
timestamp=$(date +"%Y%m%d_%H%M%S")

# 构建包含时间戳的备份目录完整路径
backup_dir="${base_backup_dir}_$timestamp"

# 确保备份目录存在
mkdir -p "$backup_dir"



# 函数，用于重写单个文件
# 假设这个函数接受文件路径和一个标识符（例如，重写版本号），并输出重写的文件
rewrite_file() {
    local file_path="$1"
    local identifier="$2"
    # 这里调用你的重写逻辑，例如一个名为 my_rewrite_command 的命令或脚本
    # 假设 my_rewrite_command 接受输入文件和输出文件作为参数
    # 并返回新的文件名作为函数输出
    new_file_name=$(my_rewrite_command "$file_path" "$identifier")
    echo "$new_file_name"
}

# 调用 Rust 程序并传递文件名列表
echo "${verilog_files[@]}" | xargs -I {} -n 1 ./main.rs

# 初始化变量
verilog_files=()  # 存储所有.v文件的路径
total_combinations=1

# 递归查找所有的.v文件，并收集文件名
while IFS= read -r -d '' file; do
    # 使用 basename 命令提取文件名并添加到数组中
    filename=$(basename "$file")
    verilog_files+=("$filename")
done < <(find "$repo_dir" -type f -name "*.v" -print0)

# 循环遍历每个.v文件，并调用可执行文件生成重写版本
for file in "${verilog_files[@]}"; do
    # 构建可执行文件的完整路径
    full_path="$repo_dir/$file"

    # 调用可执行文件，生成重写版本
    # 假设可执行文件接受.v文件的完整路径作为参数
    ./RTL_rewrite "$full_path"



    # 搜索 file_dir 目录及其所有子目录下扩展名为 .v 的文件
# 并将结果存储到 rewrite_files 数组中

rewrite_files=($(find "$file_dir" -type f -name "${file%.v}*.v"))

    # 依次用重写版本替换原始文件
    for rewrite_file in "${rewrite_files[@]}"; do
        # 构建重写文件的完整路径（这里使用相对路径）
        full_rewrite_path="$file_dir/$(basename "$rewrite_file")"

        # 替换原文件
        mv "$full_rewrite_path" "$file"

        # 打印替换信息
        echo "Replaced original file with rewrite: $(basename "$rewrite_file")"

        # 复制整个仓库到备份目录，包括替换的文件
        cp -r "$repo_dir"/* "$backup_dir"

        # 打印备份信息
        echo "Repository backup complete at $backup_dir after replacing $(basename "$file")"
    done
done



# 打印完成信息
echo "All replacements and backups are complete."

