BLANK=""
BE_HF_REGEX="${BE_PRODUCT}-hf_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_HF-[0-9][0-9][0-9]${INSTALLER_PLATFORM}"

validateInstallers "BusinessEvents" "$BE_BASE_PKG_REGEX" "$BE_HF_REGEX" "" ""

ARG_BE_VERSION=$ARG_BASE_VERSION
ARG_BE_SHORT_VERSION=$ARG_BASE_SHORT_VERSION
ARG_BE_HOTFIX=$ARG_BASE_HOTFIX
