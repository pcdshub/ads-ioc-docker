FROM centos:7

LABEL maintainer="K Lauer <klauer@slac.stanford.edu>"
USER root

# --- Version settings
ENV BASE_MODULE_TAG           R7.0.2-2.branch
ENV BASE_MODULE_VERSION       R7.0.2-2.0

ENV ADS_MODULE_VERSION        R2.0.0-0.0.4
ENV ASYN_MODULE_VERSION       R4.35-0.0.1
ENV AUTOSAVE_MODULE_VERSION   R5.8-2.1.0
ENV CALC_MODULE_VERSION       R3.7-1.0.1
ENV ETHERCATMC_MODULE_VERSION R2.1.0-0.1.0
ENV IOCADMIN_MODULE_VERSION   R3.1.15-1.10.0
ENV MOTOR_MODULE_VERSION      R6.9-ess-0.0.1
ENV SEQ_MODULE_VERSION        R2.2.4-1.1
ENV SSCAN_MODULE_VERSION      R2.10.2-1.0.0
# --- Version settings

RUN yum install -y epel-release

RUN yum groups mark convert
RUN yum groupinstall -y 'Development Tools'

RUN yum install -y glibc-common-2.17 telnet perl-CPAN openssl-devel zlib-devel qt5-qtbase-devel
RUN yum install -y git readline-devel ncurses-devel re2c

# -- Set up all git remotes
ENV GIT_MODULE_TOP https://github.com/slac-epics
ENV GIT_BASE_TOP   ${GIT_MODULE_TOP}

# -- Set up paths
ENV EPICS_SITE_TOP            /reg/g/pcds/epics

ENV BASE_MODULE_PATH          /reg/g/pcds/epics/base/${BASE_MODULE_VERSION}
ENV ADS_MODULE_PATH           /reg/g/pcds/epics/${BASE_MODULE_VERSION}/modules/twincat-ads/${ADS_MODULE_VERSION}
ENV ASYN_MODULE_PATH          /reg/g/pcds/epics/${BASE_MODULE_VERSION}/modules/asyn/${ASYN_MODULE_VERSION}
ENV AUTOSAVE_MODULE_PATH      /reg/g/pcds/epics/${BASE_MODULE_VERSION}/modules/autosave/${AUTOSAVE_MODULE_VERSION}
ENV CALC_MODULE_PATH          /reg/g/pcds/epics/${BASE_MODULE_VERSION}/modules/calc/${CALC_MODULE_VERSION}
ENV ETHERCATMC_MODULE_PATH    /reg/g/pcds/epics/${BASE_MODULE_VERSION}/modules/ethercatmc/${ETHERCATMC_MODULE_VERSION}
ENV IOCADMIN_MODULE_PATH      /reg/g/pcds/epics/${BASE_MODULE_VERSION}/modules/iocAdmin/${IOCADMIN_MODULE_VERSION}
ENV MOTOR_MODULE_PATH         /reg/g/pcds/epics/${BASE_MODULE_VERSION}/modules/motor/${MOTOR_MODULE_VERSION}
ENV SSCAN_MODULE_PATH         /reg/g/pcds/epics/${BASE_MODULE_VERSION}/modules/sscan/${SSCAN_MODULE_VERSION}
ENV SEQ_MODULE_PATH           /reg/g/pcds/epics/${BASE_MODULE_VERSION}/modules/seq/${SEQ_MODULE_VERSION}

ENV EPICS_BASE                      ${BASE_MODULE_PATH}
ENV EPICS_HOST_ARCH                 rhel7-x86_64
ENV EPICS_SETUP                     /reg/g/pcds/setup
ENV EPICS_CA_REPEATER_PORT          5065
ENV EPICS_PVA_SERVER_PORT           5075
ENV EPICS_BASE                      /reg/g/pcds/epics/base/R7.0.2-2.0
ENV EPICS_PVA_AUTO_ADDR_LIST        YES
ENV EPICS_CA_AUTO_ADDR_LIST         YES
ENV EPICS_HOST_ARCH                 rhel7-x86_64
ENV EPICS_PVA_BROADCAST_PORT        5076
ENV EPICS_CA_BEACON_PERIOD          15.0
ENV EPICS_CA_CONN_TMO               30.0
ENV EPICS_CA_MAX_SEARCH_PERIOD      300
ENV EPICS_MODULES                   /reg/g/pcds/epics/R7.0.2-2.0/modules
ENV EPICS_CA_MAX_ARRAY_BYTES        40000000
ENV EPICS_CA_SERVER_PORT            5064
# ENV EPICS_EXTENSIONS                /reg/g/pcds/epics/extensions/R0.2.0
# ENV EPICS_REPO                      file:///afs/slac/g/pcds/vol2/svn/pcds

WORKDIR ${EPICS_SITE_TOP}

# -- Clone specific versions of the required modules
COPY deps/RELEASE_SITE ${EPICS_SITE_TOP}/${BASE_MODULE_VERSION}/modules/RELEASE_SITE

RUN git clone --depth 0 --branch ${BASE_MODULE_TAG} -- $GIT_BASE_TOP/epics-base.git ${BASE_MODULE_PATH}
RUN git clone --depth 0 --branch ${ASYN_MODULE_VERSION} -- $GIT_MODULE_TOP/asyn.git ${ASYN_MODULE_PATH}
RUN git clone --recursive --depth 0 --branch ${ADS_MODULE_VERSION} -- $GIT_MODULE_TOP/twincat-ads.git ${ADS_MODULE_PATH}
RUN git clone --depth 0 --branch ${CALC_MODULE_VERSION} -- $GIT_MODULE_TOP/calc.git ${CALC_MODULE_PATH}
RUN git clone --depth 0 --branch ${IOCADMIN_MODULE_VERSION} -- $GIT_MODULE_TOP/iocAdmin.git ${IOCADMIN_MODULE_PATH}
RUN git clone --depth 0 --branch ${AUTOSAVE_MODULE_VERSION} -- $GIT_MODULE_TOP/autosave.git ${AUTOSAVE_MODULE_PATH}
RUN git clone --depth 0 --branch ${MOTOR_MODULE_VERSION} -- $GIT_MODULE_TOP/motor.git ${MOTOR_MODULE_PATH}
RUN git clone --depth 0 --branch ${ETHERCATMC_MODULE_VERSION} -- $GIT_MODULE_TOP/ethercatmc.git ${ETHERCATMC_MODULE_PATH}
RUN git clone --depth 0 --branch ${SSCAN_MODULE_VERSION} -- $GIT_MODULE_TOP/sscan.git ${SSCAN_MODULE_PATH}
RUN git clone --depth 0 --branch ${SEQ_MODULE_VERSION} -- $GIT_MODULE_TOP/seq.git ${SEQ_MODULE_PATH}

# - Build all of the dependencies
RUN make -C ${BASE_MODULE_PATH} CROSS_COMPILER_TARGET_ARCHS= all clean
RUN make -C ${ASYN_MODULE_PATH} all clean
RUN make -C ${ADS_MODULE_PATH} all clean
RUN make -C ${CALC_MODULE_PATH} all clean
RUN make -C ${AUTOSAVE_MODULE_PATH} all clean
RUN make -C ${IOCADMIN_MODULE_PATH} all clean
RUN make -C ${MOTOR_MODULE_PATH} all clean

RUN make -C ${SEQ_MODULE_PATH} RE2C="$(command -v re2c)" all clean
RUN make -C ${SSCAN_MODULE_PATH} all clean

WORKDIR ${ETHERCATMC_MODULE_PATH}
RUN sed -i -e 's/^CALC_MODULE_VERSION.*=.*$/CALC_MODULE_VERSION = R3.7-1.0.1/' configure/RELEASE.local
RUN make -C ${ETHERCATMC_MODULE_PATH} all clean

# - And the ADS IOC
WORKDIR /epics/iocs
ENV ADS_IOC_PATH /epics/iocs/ads-ioc
RUN git clone file://${GIT_EPICS_TOP}/modules/ads-ioc.git ${ADS_IOC_PATH}
RUN make -C ${ADS_IOC_PATH} all clean

WORKDIR ${ADS_IOC_PATH}/bin/${EPICS_HOST_ARCH}
ENTRYPOINT ["./adsIoc"]
