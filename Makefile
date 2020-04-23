AIRMAP_PROTOS_PATH = interfaces/grpc
AIRMAP_PROTOS := $(shell find $(AIRMAP_PROTOS_PATH) -name '*.proto')

GOOGLE_PROTOS_PATH = .build/protobuf/src/google/protobuf

TARGET_PROTO_PATH = Source/Telemetry/grpc
SWIFT_BUILD_PATH:= .build/grpc-swift/.build/release
PROTOC_GEN_SWIFT=${SWIFT_BUILD_PATH}/protoc-gen-swiftgrpc
PROTOC_GEN_GRPC_SWIFT=${SWIFT_BUILD_PATH}/protoc-gen-grpc-swift


all: bootstrap protos
from-scratch: really-clean bootstrap protos
protos: 	
	@mkdir -p $(TARGET_PROTO_PATH)
	@for x in $(AIRMAP_PROTOS); do \
		protoc $$x -I$(AIRMAP_PROTOS_PATH) -I$(GOOGLE_PROTOS_PATH) --swift_out=$(TARGET_PROTO_PATH) --grpc-swift_out=$(TARGET_PROTO_PATH) --plugin=${PROTOC_GEN_SWIFT} --plugin=${PROTOC_GEN_GRPC_SWIFT}; \
	 done

# protos:
# 	mkdir -p TARGET_PROTO_PATH || true
# 	protoc $(AIRMAP_PROTOS) \
# 		--plugin=${PROTOC_GEN_SWIFT} \
# 		--plugin=${PROTOC_GEN_GRPC_SWIFT} \
# 		--swift_out=$(TARGET_PROTO_PATH) \
# 		--swiftgrpc_out=$(TARGET_PROTO_PATH) \
# 		-I$(AIRMAP_PROTOS_PATH) \
# 		-I$(GOOGLE_PROTOS_PATH) \
		

bootstrap:
	git clone https://github.com/grpc/grpc-swift .build/grpc-swift || true
	git clone https://github.com/protocolbuffers/protobuf .build/protobuf || true
	make -C .build/grpc-swift plugins
	# Renaming plugin to expected name
	cd .build/grpc-swift/.build/release && mv -f protoc-gen-swift protoc-gen-swiftgrpc

clean:
	rm -rf $(TARGET_PROTO_PATH) || true

really-clean: clean
	rm -rf .build || true