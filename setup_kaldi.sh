#!/bin/bash

# 一. 更新和升級系統
echo "更新系統..."
sudo apt update && sudo apt upgrade -y

# 二. 安裝 Kaldi 所需依賴包
echo "安裝 Kaldi 所需的依賴包..."
sudo apt install -y build-essential zlib1g-dev automake autoconf \
libtool subversion python3 python3-pip sox gfortran \
libatlas-base-dev

# 三. 安裝 OpenFst
echo "安裝 OpenFst..."
sudo apt install -y libopenblas-dev

# 四. 下載 Kaldi
echo "下載 Kaldi..."
cd ~
if [ ! -d "kaldi" ]; then
    git clone https://github.com/kaldi-asr/kaldi.git
else
    echo "Kaldi 已存在，跳過下載。"
fi

# 五. 安裝 Kaldi 工具
echo "安裝 Kaldi 工具..."
cd kaldi/tools
make -j $(nproc)

# 安裝 OpenBLAS (加速數學計算)
echo "安裝 OpenBLAS..."
extras/install_openblas.sh

# 六. 編譯 Kaldi
echo "編譯 Kaldi..."
cd ../src
./configure --shared
make depend -j $(nproc)
make -j $(nproc)

# 七. 測試 Kaldi 是否正常運行
echo "執行 Kaldi 測試..."
cd ~/kaldi/egs/yesno/s5
./run.sh

if [ $? -eq 0 ]; then
    echo "Kaldi 安裝成功且測試通過！"
else
    echo "Kaldi 測試失敗，請檢查日誌以解決問題。"
fi

echo "全部步驟完成！"
