MAKEFLAGS += --silent
SRC_DIR=driver_src
BASE_SCRIPT=base/base_script.sh
OUT_DIR=out
TARGET=$(OUT_DIR)/mtk-driver.run

TAR=tar

build:
	mkdir out
	cp $(BASE_SCRIPT) $(TARGET)
	$(TAR) -czf - $(SRC_DIR) >> $(TARGET)
	chmod +x $(TARGET)
	echo "file is saved in $(OUT_DIR)"
clean:
	rm -rf $(OUT_DIR)
