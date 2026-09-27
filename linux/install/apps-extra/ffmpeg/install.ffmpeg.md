# FFmpeg Installation Guide

## Method 1: Install from Software Repository

To install FFmpeg from the default software repository, run:

```bash
sudo apt-get install ffmpeg
```

## Method 2: Compile Latest Version from Source (Recommended)

To compile the latest version of FFmpeg from source, follow these steps:

### 1. Install Dependencies

```bash
sudo apt-get install libopus-dev libmp3lame-dev libfdk-aac-dev libvpx-dev libx264-dev yasm libass-dev libtheora-dev libvorbis-dev mercurial cmake build-essential
```

### 2. Compile x265

```bash
mkdir ~/ffmpeg; cd ~/ffmpeg
git clone https://bitbucket.org/multicoreware/x265_git.git
cd x265_git/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source && PATH="$HOME/bin:$PATH"
sudo make && sudo make install
```

### 3. Compile FFmpeg

```bash
if [ -d ~/ffmpeg ]; then cd ~/ffmpeg; else mkdir ~/ffmpeg && cd ~/ffmpeg; fi
wget -O- http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 | tar xj
cd ~/ffmpeg/ffmpeg

PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" \
   ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree && \
PATH="$HOME/bin:$PATH" sudo make && sudo make install
```

### 4. Verify Installation

```bash
ffmpeg -version
```

### Updating the Compiled Version

To update the compiled version, first remove the current build and then repeat the steps
in Method 2:

```bash
rm -rf ~/ffmpeg ~/ffmpeg_build ~/bin/{ffmpeg,ffprobe,ffplay,x264,x265}
```
