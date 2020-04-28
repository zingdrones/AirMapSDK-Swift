AIRMAP_PROTOS_PATH = interfaces/airmap/public/grpc
GOOGLE_PROTOS_PATH = .build/protobuf/src/google/protobuf

CORE_PROTOS = \
	$(AIRMAP_PROTOS_PATH)/ids/ids.proto \
	$(AIRMAP_PROTOS_PATH)/measurements/measurements.proto \
	$(AIRMAP_PROTOS_PATH)/units/units.proto \

CORE_PROTOS_TARGET_PATH = Source/Core/Generated

TELEMETRY_PROTOS = \
	$(AIRMAP_PROTOS_PATH)/telemetry/telemetry.proto \
	$(AIRMAP_PROTOS_PATH)/telemetry/report.proto \
	$(AIRMAP_PROTOS_PATH)/tracking/emitter.proto \
	$(AIRMAP_PROTOS_PATH)/tracking/identity.proto \
	$(AIRMAP_PROTOS_PATH)/tracking/sensors.proto \
	$(AIRMAP_PROTOS_PATH)/tracking/track.proto \
	$(AIRMAP_PROTOS_PATH)/tracking/tracking.proto \
	$(AIRMAP_PROTOS_PATH)/system/ack.proto \
	$(AIRMAP_PROTOS_PATH)/system/status.proto \

TELEMETRY_PROTOS_TARGET_PATH = Source/Telemetry/Generated

all: bootstrap protos
from-scratch: really-clean bootstrap protos

protos: clean
	mkdir -p $(CORE_PROTOS_TARGET_PATH)
	protoc \
		--swift_out=$(CORE_PROTOS_TARGET_PATH) \
		--swift_opt=Visibility=Public \
		--swiftgrpc_out=Client=true,Server=false:$(CORE_PROTOS_TARGET_PATH) \
		-I$(AIRMAP_PROTOS_PATH) \
		-I$(GOOGLE_PROTOS_PATH) \
		$(CORE_PROTOS)

	mkdir -p $(TELEMETRY_PROTOS_TARGET_PATH)
	protoc \
		--swift_out=$(TELEMETRY_PROTOS_TARGET_PATH) \
		--swift_opt=Visibility=Public \
		--swiftgrpc_out=Client=true,Server=false:$(TELEMETRY_PROTOS_TARGET_PATH) \
		-I$(AIRMAP_PROTOS_PATH) \
		-I$(GOOGLE_PROTOS_PATH) \
		$(TELEMETRY_PROTOS)

bootstrap:
	git clone https://github.com/grpc/grpc-swift .build/grpc-swift || true
	git clone https://github.com/protocolbuffers/protobuf .build/protobuf || true
	make -C .build/grpc-swift plugins
	# Renaming plugin to expected name
	cd .build/grpc-swift/.build/release && mv -f protoc-gen-grpc-swift protoc-gen-swiftgrpc

clean:
	rm -rf $(CORE_PROTOS_TARGET_PATH) || true
	rm -rf $(TELEMETRY_PROTOS_TARGET_PATH) || true

really-clean: clean
	rm -rf .build || true
