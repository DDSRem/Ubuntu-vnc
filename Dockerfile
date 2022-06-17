## 安装novnc
FROM ubuntu:18.04
# 环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    SIZE=1024x768 \
    PASSWD=123456 \
    TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=${LANG} \
    LANGUAGE=${LANG}

USER root
WORKDIR /root

# 设定密码
RUN echo "root:$PASSWD" | chpasswd

# 安装
RUN apt-get -y update && \
    # tools
    apt-get install -y vim nano git subversion wget curl net-tools locales bzip2 unzip iputils-ping traceroute firefox firefox-locale-zh-hans ttf-wqy-microhei gedit ibus-pinyin && \
    locale-gen zh_CN.UTF-8 && \
    # TigerVNC
    wget -qO- https://nchc.dl.sourceforge.net/project/tigervnc/stable/1.10.1/tigervnc-1.10.1.x86_64.tar.gz | tar xz --strip 1 -C / && \
    mkdir -p /root/.vnc && \
    echo $PASSWD | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    # xfce
    apt-get install -y xfce4 xfce4-terminal && \
    apt-get purge -y pm-utils xscreensaver* && \
    # 谷歌浏览器
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y -f ./google-chrome-stable_current_amd64.deb && \
    sed -e '/chrome/ s/^#*/#/' -i /opt/google/chrome/google-chrome && \
    echo 'exec -a "$0" "$HERE/chrome" "$@" --user-data-dir="$HOME/.config/chrome" --no-sandbox --disable-dev-shm-usage' >> /opt/google/chrome/google-chrome && \
    rm -f google-chrome-stable_current_amd64.deb && \
    # Wine
    apt update && \ 
    apt install -y wget software-properties-common && \ 
    dpkg --add-architecture i386 && \ 
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \ 
    apt update && \
    apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' && \ 
    apt update && \ 
    apt install winehq-stable -y && \ 
    apt remove -y software-properties-common && \
    wget http://mirrors.ustc.edu.cn/wine/wine/wine-mono/7.2.0/wine-mono-7.2.0-x86.msi && \
    wine start /i wine-mono-7.2.0-x86.msi && \
    rm -rf /root/wine-mono-7.2.0-x86.msi

# 配置xfce图形界面
ADD ./xfce/ /root/

# 配置noVNC
COPY ./noVNC /root/noVNC

# clean
RUN apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY startup.sh /root
RUN chmod +x /root/startup.sh

RUN LANG=C xdg-user-dirs-update --force

EXPOSE 5900 6080

ENV WINEDEBUG -all

CMD ["/root/startup.sh"]