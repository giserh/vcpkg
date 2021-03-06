include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ACE_wrappers/ace)
vcpkg_download_distfile(ARCHIVE
    URL "http://download.dre.vanderbilt.edu/previous_versions/ACE-6.4.0.zip"
    FILENAME "ACE-6.4.0.zip"
    SHA512 3543291332b96cf06a966dedda617169e8db051cebbbc4f05cdc2c2c9e7908174f8ed67bc152bbcd57541279d3addb1138f1fc092468e856c2bb04ee6ad2b95a
)
vcpkg_extract_source_archive(${ARCHIVE})

if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR, "ARM is currently not supported.")
    return()
elseif (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

# Add ace/config.h file 
# see http://www.dre.vanderbilt.edu/~schmidt/DOC_ROOT/ACE/ACE-INSTALL.html#win32
file(WRITE ${SOURCE_PATH}/config.h "#include \"ace/config-windows.h\"")
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/ace_vc14.sln
    PLATFORM ${MSBUILD_PLATFORM}
)

# ACE itself does not define an install target, so it is not clear which 
# headers are public and which not. For the moment we install everything 
# that is in the source path and ends in .h, .inl
function(install_ace_headers_subdirectory SOURCE_PATH RELATIVE_PATH)
    file(GLOB HEADER_FILES ${SOURCE_PATH}/${RELATIVE_PATH}/*.h ${SOURCE_PATH}/${RELATIVE_PATH}/*.inl)
    file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ace/${RELATIVE_PATH})
endfunction()

# We manually install header found in the ace directory because in that case 
# we are supposed to install also *cpp files, see ACE_wrappers\debian\libace-dev.install file 
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h ${SOURCE_PATH}/*.inl ${SOURCE_PATH}/*.cpp)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ace/)

# Install headers in subdirectory
install_ace_headers_subdirectory(${SOURCE_PATH} "Compression")
install_ace_headers_subdirectory(${SOURCE_PATH} "Compression/rle")
install_ace_headers_subdirectory(${SOURCE_PATH} "ETCL")
install_ace_headers_subdirectory(${SOURCE_PATH} "Monitor_Control")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include/arpa")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include/net")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include/netinet")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include/sys")

# Install the libraries
function(install_ace_library SOURCE_PATH ACE_LIBRARY)
    set(LIB_PATH ${SOURCE_PATH}/../lib/)
    file(INSTALL
        ${LIB_PATH}/${ACE_LIBRARY}d.dll
        ${LIB_PATH}/${ACE_LIBRARY}d_dll.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )

    file(INSTALL
        ${LIB_PATH}/${ACE_LIBRARY}.dll
        ${LIB_PATH}/${ACE_LIBRARY}.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
    
    file(INSTALL
        ${LIB_PATH}/${ACE_LIBRARY}d.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )

    file(INSTALL
        ${LIB_PATH}/${ACE_LIBRARY}.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
endfunction()

install_ace_library(${SOURCE_PATH} "ACE")
install_ace_library(${SOURCE_PATH} "ACE_Compression")
install_ace_library(${SOURCE_PATH} "ACE_ETCL")
install_ace_library(${SOURCE_PATH} "ACE_Monitor_Control")
install_ace_library(${SOURCE_PATH} "ACE_QoS")
install_ace_library(${SOURCE_PATH} "ACE_RLECompression")

# Handle copyright
file(COPY ${SOURCE_PATH}/../COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ace)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ace/COPYING ${CURRENT_PACKAGES_DIR}/share/ace/copyright)
