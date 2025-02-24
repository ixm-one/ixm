cmake_language(CALL 🈯::ixm::experiment find.windows "4854aabb-2bc6-5fe7-9bda-da57becb0581")

cmake_language(CALL ixm::find::library COMPONENT Shell NAMES shlwapi HEADER shlwapi.h)

# MediaFoundation
# https://learn.microsoft.com/en-us/windows/win32/medfound/media-foundation-headers-and-libraries

#cmake_language(CALL ixm::package::component
#  NAME MediaFoundation
#  TYPE Library
#  LIBRARIES
#    dxva2
#    evr
#    mf
#    mfplay
#    mfreadwrite
#    mfuuid
#  HEADERS
#    codecapi.h
#    d3d11.h
#    d3d9.h
#    d3d9caps.h
#    d3d9types.h
#    dxva.h
#    dxva2api.h
#    dxvahd.h
#    evr.h
#    evr9.h
#    mfapi.h
#    mfcaptureengine.h
#    mferrors.h
#    mfidl.h
#    mfmediacapture.h
#    mfmediaengine.h
#    mfmp2dlna.h
#    mfobjects.h
#    mfplat.lib
#    mfplay.h
#    mfreadwrite.h
#    mftransform.h
#    opmapi.h
#    wmcodecdsp.h
#    wmcontainer.h)

cmake_language(CALL ixm::find::library COMPONENT Sockets NAME Ws2_32 HEADER ws2tcpip.h)

cmake_language(CALL ixm::package::check)

cmake_language(CALL ixm::package::properties
  DESCRIPTION "Win32 API Libraries"
  URL "https://learn.microsoft.com/en-us/windows/win32/api/")
