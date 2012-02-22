# Configure the directories where you want hadoop installed
HADOOP_HOME=$HOME/BigData
HADOOP_DOWNLOADS=$HADOOP_HOME/Downloads
HADOOP_DATA=$HADOOP_HOME/Data
HADOOP_DATA_TMP=$HADOOP_HOME/Data/tmp
HADOOP_LOGS=$HADOOP_HOME/Logs/hadoop
HADOOP_CONFIG=$HADOOP_HOME/Configs/hadoop
HADOOP_ENV=
#### Hadoop Base
hadoop=http://archive.cloudera.com/cdh/3/hadoop-0.20.2-cdh3u2.tar.gz
hive=http://archive.cloudera.com/cdh/3/hive-0.7.1-cdh3u2.tar.gz
hbase=http://archive.cloudera.com/cdh/3/hbase-0.90.4-cdh3u2.tar.gz

## Cascading
cascading="http://files.cascading.org/cascading/1.2/cascading-1.2.5-hadoop-0.19.2+.tgz"
cascading_word=http://files.cascading.org/samples/wordcount-20101201.tgz
cascading_logparser=http://files.cascading.org/samples/logparser-20101201.tgz
cascading_loganalysis=http://files.cascading.org/samples/loganalysis-20101201.tgz

#### DO NOT EDIT BELOW THIS LINE ####
function make_dir(){
  mkdir -p $1
}
#Ensure directories exist
make_dir $HADOOP_HOME
make_dir $HADOOP_DATA
make_dir $HADOOP_DATA_TMP
make_dir $HADOOP_DOWNLOADS

function sanitize_filename(){
  echo $1 | sed -e 's/.tar.gz//g' -e 's/.tgz//g'
}

function download(){
  file=$1/$(basename $2)
  if [ -f $file ];
  then
     echo "File $file exists."
  else
     echo "File $file does not exist. Will download"
     pushd $1
     wget $2
     popd
  fi
}
function extract(){
  file=$(basename $2)
  target=$1/$(sanitize_filename $file)
  echo "Checking extract target: $target"
  if [ -d $target ];
  then
    echo "File $file exists. Will not extract"
  else
    pushd $1
    mkdir $(sanitize_filename $file)
    tar xvzf $(basename $2) -C $(sanitize_filename $file) --strip-components 1
    popd
  fi
}
function link(){
  file=$(basename $3)
  directory=$(sanitize_filename $file)
  symlink=$(echo $directory | sed 's/-*-.*//g')
  targetdir=$1/$symlink
  echo "Directory: $directory"
  echo "Checking dir: $targetdir"
  if [ -e $targetdir ];
  then
    echo "Removing symlink"
    rm $1/$symlink
  fi
  ln -s $2/$directory $1/$symlink
  echo "Creating symlink: $symlink"
}
function create_symlink(){
  source=$1
  dest=$2
  if [ -e "$dest" ];
  then
    echo "Removing $dest symlink"
    rm $dest
  fi
  ln -s $source $dest
}
function move_and_symlink_config(){
  if [ ! -e "$2.bk" ];
  then
    echo "Has not been backed up: $2.bk"
    mv $2 $2.bk
  fi
  if [ -e "$2" ];
  then
    echo "Removing $2 symlink"
    rm $2
  fi
  ln -s $1 $2
}
function download_extract_link(){
  # Download files
  download $HADOOP_DOWNLOADS $1
  #extract files
  extract $HADOOP_DOWNLOADS $1
  #synlink files
  link $HADOOP_HOME $HADOOP_DOWNLOADS $1
}
function download_extract_link_cascade_example(){
  download $HADOOP_DOWNLOADS/cascading_examples $1
  extract $HADOOP_DOWNLOADS/cascading_examples $1
  link $HADOOP_HOME/cascading/examples $HADOOP_DOWNLOADS/cascading_examples $1
}
download_extract_link $hadoop
download_extract_link $hive
download_extract_link $hbase

#symlink data folder to make upgrades easier
create_symlink $HADOOP_DATA $HADOOP_HOME/hadoop/data
create_symlink $HADOOP_LOGS $HADOOP_HOME/hadoop/logs
move_and_symlink_config $HADOOP_CONFIG $HADOOP_HOME/hadoop/conf

# cascading specific things
download_extract_link $cascading
make_dir $HADOOP_DOWNLOADS/cascading_examples
make_dir $HADOOP_HOME/cascading/examples

download_extract_link_cascade_example $cascading_word
download_extract_link_cascade_example $cascading_logparser
download_extract_link_cascade_example $cascading_loganalysis


