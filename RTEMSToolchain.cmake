################################################################################
# RTEMS toolchain path configuration
################################################################################

# This file can be loaded with -DCMAKE_TOOLCHAIN_FILE, but we need to
# disable the checks anyway.. RTEMSConfig.make prefered for now.

set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_CROSSCOMPILING 1)

set(RTEMS_PREFIX ${RTEMS_PREFIX} CACHE FILEPATH "RTEMS prefix")
set(RTEMS_BSP ${RTEMS_BSP} CACHE STRING "RTEMS BSP pair")

set(RTEMS_INSTALL 
	${CMAKE_INSTALL_PREFIX} 
	CACHE FILEPATH "RTEMS install destination"
)

if(NOT RTEMS_PATH)
	message(STATUS 
		"RTEMS path was not specified and was set to RTEMS prefix."
	)
	set(RTEMS_PATH ${RTEMS_PREFIX} CACHE FILEPATH "RTEMS folder")
else()
	set(RTEMS_TOOLS ${RTEMS_PATH} CACHE FILEPATH "RTEMS path folder")
endif()

if(NOT RTEMS_TOOLS)
	message(STATUS 
		"RTEMS toolchain path was not specified and was set to RTEMS prefix."
	)
	set(RTEMS_TOOLS ${RTEMS_PREFIX} CACHE FILEPATH "RTEMS tools folder")
else()
	set(RTEMS_TOOLS ${RTEMS_TOOLS} CACHE FILEPATH "RTEMS tools folder")
endif()

if(NOT RTEMS_VERSION)
	message(STATUS "No RTEMS_VERSION supplied.")
    message(STATUS "Autodetermining version from tools path ${RTEMS_TOOLS} ..")
    string(REGEX MATCH [0-9]+$ RTEMS_VERSION "${RTEMS_TOOLS}")
    message(STATUS "Version ${RTEMS_VERSION} found")
endif()

set(RTEMS_VERSION "${RTEMS_VERSION}" CACHE STRING "RTEMS version")

message(STATUS "Setting up and checking RTEMS cross compile configuration..")

string(REPLACE "/" ";" RTEMS_BSP_LIST_SEPARATED ${RTEMS_BSP})
message(STATUS "${RTEMS_BSP_LIST_SEPARATED}") 
list(LENGTH RTEMS_BSP_LIST_SEPARATED BSP_LIST_SIZE)

if(NOT ${BSP_LIST_SIZE} EQUAL 2)
    message(FATAL_ERROR 
    	"Supplied RTEMS_BSP variable invalid. " 
    	"Make sure to provide a slash separated string"
    )
endif()

list(GET RTEMS_BSP_LIST_SEPARATED 0 RTEMS_ARCH_NAME)
list(GET RTEMS_BSP_LIST_SEPARATED 1 RTEMS_BSP_NAME)

set(RTEMS_ARCH_TOOLS "${RTEMS_ARCH_NAME}-rtems${RTEMS_VERSION}")

if(NOT IS_DIRECTORY "${RTEMS_PATH}/${RTEMS_ARCH_TOOLS}")
	message(FATAL_ERROR 
		"RTEMS architecure folder not found at "
		"${RTEMS_PATH}/${RTEMS_ARCH_TOOLS}"
	)
endif()
    
set(RTEMS_BSP_PATH "${RTEMS_PATH}/${RTEMS_ARCH_TOOLS}/${RTEMS_BSP_NAME}")
if(NOT IS_DIRECTORY ${RTEMS_BSP_PATH})
	message(STATUS 
		"Supplied or autodetermined BSP path "
		"${RTEMS_BSP_PATH} is invalid!"
	)
	message(FATAL_ERROR 
		"Please check the BSP path or make sure " 
		"the BSP is installed."
	)
endif()

set(RTEMS_BSP_LIB_PATH "${RTEMS_BSP_PATH}/lib")
if(NOT IS_DIRECTORY "${RTEMS_BSP_LIB_PATH}") 
	message(FATAL_ERROR 
		"RTEMS BSP lib folder not found at "
		"${RTEMS_BSP_LIB_PATH}"
	)
endif()
set(RTEMS_BSP_INC_PATH "${RTEMS_BSP_LIB_PATH}/include")
if(NOT IS_DIRECTORY "${RTEMS_BSP_INC_PATH}")
	message(FATAL_ERROR 
		"RTEMS BSP include folder not found at "
		"${RTEMS_BSP_INC_PATH}"
	)
endif()


################################################################################
# Checking the toolchain
################################################################################

message(STATUS "Checking for RTEMS binaries folder..")
set(RTEMS_BIN_PATH "${RTEMS_TOOLS}/bin")
if(NOT IS_DIRECTORY "${RTEMS_BIN_PATH}")
	message(FATAL_ERROR "RTEMS binaries folder not found at ${RTEMS_TOOLS}/bin")
endif()

message(STATUS "Checking for RTEMS gcc..")
set(RTEMS_GCC "${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-gcc")
if(NOT EXISTS "${RTEMS_GCC}") 
	message(FATAL_ERROR 
		"RTEMS gcc compiler not found at "
		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-gcc"
	)
endif()

message(STATUS "Checking for RTEMS g++..")
set(RTEMS_GXX "${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-g++")
if(NOT EXISTS "${RTEMS_GXX}")
	message(FATAL_ERROR 
		"RTEMS g++ compiler not found at " 
		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-g++"
	)
endif()

message(STATUS "Checking for RTEMS assembler..")
set(RTEMS_ASM "${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-as")
if(NOT EXISTS "${RTEMS_GXX}")
	message(FATAL_ERROR 
		"RTEMS as compiler not found at " 
		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-as")
endif()

message(STATUS "Checking for RTEMS linker..")
set(RTEMS_LINKER "${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-ld")
if(NOT EXISTS "${RTEMS_LINKER}")
	message(FATAL_ERROR 
		"RTEMS ld linker  not found at "
		"${RTEMS_BIN_PATH}/${RTEMS_ARCH_TOOLS}-ld")
endif()

message(STATUS "Checking done")

############################################
# Info output
###########################################

message(STATUS "RTEMS version: ${RTEMS_VERSION}")
message(STATUS "RTEMS prefix: ${RTEMS_PREFIX}")
message(STATUS "RTEMS tools path: ${RTEMS_TOOLS}")
message(STATUS "RTEMS BSP pair: ${RTEMS_BSP}")
message(STATUS "RTEMS architecture tools path: "
	"${RTEMS_PATH}/${RTEMS_ARCH_TOOLS}")
message(STATUS "RTEMS BSP library path: ${RTEMS_BSP_LIB_PATH}")
message(STATUS "RTEMS BSP include path: ${RTEMS_BSP_INC_PATH}")
message(STATUS "RTEMS install target: ${RTEMS_INSTALL}")

message(STATUS "RTEMS gcc compiler: ${RTEMS_GCC}")
message(STATUS "RTEMS g++ compiler: ${RTEMS_GXX}")
message(STATUS "RTEMS assembler: ${RTEMS_ASM}")
message(STATUS "RTEMS linker: ${RTEMS_LINKER}")

if(${RTEMS_ARCH_NAME} STREQUAL "arm")
    set(CMAKE_SYSTEM_PROCESSOR arm PARENT_SCOPE)
endif()
	
###############################################################################
# Setting variables in upper scope (only the upper scope!)
###############################################################################

set(CMAKE_C_COMPILER ${RTEMS_GCC})
set(CMAKE_CXX_COMPILER ${RTEMS_GXX})
set(CMAKE_ASM_COMPILER ${RTEMS_ASM})
set(CMAKE_LINKER ${RTEMS_LINKER})

set(RTEMS_BSP_LIB_PATH ${RTEMS_BSP_LIB_PATH} CACHE FILEPATH "BSP library path")
set(RTEMS_BSP_INC_PATH ${RTEMS_BSP_INC_PATH} CACHE FILEPATH "BSP include path")
set(RTEMS_ARCH_LIB_PATH ${RTEMS_BSP_INC_PATH} 
	CACHE FILEPATH "Architecture library path"
)