#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241014
#  History:  20241110
#  --ref: QIIME 2チュートリアル：https://docs.qiime2.org/2024.10/tutorials/moving-pictures/
#============================================================================================================

#conda環境構築とQIIME 2のインストール
conda env create -n qiime2-amplicon-2024.10 --file https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.10-py310-linux-conda.yml
conda activate qiime2-amplicon-2024.10

#作業ディレクトリの作成
mkdir qiime

#サンプルデータ(demultiplexed paired-end)とデータベースのダウンロード
wget   -P qiime https://data.qiime2.org/2024.10/tutorials/importing/casava-18-paired-end-demultiplexed.zip
unzip  -d qiime qiime/casava-18-paired-end-demultiplexed.zip 
wget   -P qiime https://data.qiime2.org/classifiers/sklearn-1.4.2/silva/silva-138-99-nb-classifier.qza

#配列データをQIIME 2で扱える形式にインポートする
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path   qiime/casava-18-paired-end-demultiplexed \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path  qiime/demux-paired-end.qza

#DADA2によるノイズ除去とASV作成
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs qiime/demux-paired-end.qza\
  --p-trunc-len-f 0\
  --p-trunc-len-r 0\
  --o-representative-sequences qiime/rep-seqs-dada2.qza \
  --o-table           qiime/table-dada2.qza \
  --o-denoising-stats qiime/stats-dada2.qza

#結果の統計値をテーブルに出力
qiime metadata tabulate \
  --m-input-file    qiime/stats-dada2.qza \
  --o-visualization qiime/stats-dada2.qzv

#系統アサインメント
qiime feature-classifier classify-sklearn \
  --i-classifier     qiime/silva-138-99-nb-classifier.qza \
  --i-reads          qiime/rep-seqs-dada2.qza \
  --o-classification qiime/taxonomy.qza

#棒グラフなどのサマリー画面の作成
qiime taxa barplot \
  --i-table         qiime/table-dada2.qza \
  --i-taxonomy      qiime/taxonomy.qza \
  --o-visualization qiime/taxa-bar-plots.qzv

