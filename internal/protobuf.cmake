include_guard(GLOBAL)

# This is a temporary file until we can move this into the specific module.
message(TRACE "Setting default properties")
block (SCOPE_FOR VARIABLES)
  set_property(GLOBAL PROPERTY 🈯::ixm::protobuf::objc::source .pbobjc.m)
  set_property(GLOBAL PROPERTY 🈯::ixm::protobuf::objc::header .pbobjc.h)
  set_property(GLOBAL PROPERTY 🈯::ixm::protobuf::cxx::source .pb.cc)
  set_property(GLOBAL PROPERTY 🈯::ixm::protobuf::cxx::header .pb.h)

  set_property(GLOBAL PROPERTY 🈯::ixm::grpc::objc::source .pbrpc.m)
  set_property(GLOBAL PROPERTY 🈯::ixm::grpc::objc::header .pbrpc.h)
  set_property(GLOBAL PROPERTY 🈯::ixm::grpc::cxx::source .grpc.pb.cc)
  set_property(GLOBAL PROPERTY 🈯::ixm::grpc::cxx::header .grpc.pb.h)

  set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMake")
  set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED YES) # Removes CDash Targets
endblock()

message(TRACE "Defining custom protobuf properties")
block (SCOPE_FOR VARIABLES)
  set(properties FATAL_WARNINGS OUTPUT_DIRECTORY OPTIONS_PLUGINS PATHS ERROR_FORMAT LANGUAGE)
  foreach (property IN LISTS properties)
    define_property(TARGET
      PROPERTY PROTOBUF_${property}
      INITIALIZE_FROM_VARIABLE IXM_PROTOBUF_${property})
  endforeach()
endblock()

message(TRACE "Initializing IXM property defaults")
if (CMAKEE_GENERATOR MATCHES "^Visual Studio")
  set(IXM_PROTOBUF_ERROR_FORMAT "msvs" CACHE INTERNAL "Protobuf error format")
endif()
