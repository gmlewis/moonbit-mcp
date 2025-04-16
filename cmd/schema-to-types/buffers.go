package main

import (
	"bytes"
	"os"
	"path/filepath"
)

type outBufsT struct {
	// enums and structs defined in types.mbt
	typesFile bytes.Buffer
	// ToJson and FromJson trait implementations defined in types-json.mbt
	typesJSONFile bytes.Buffer
	// ::new functions defined in types-new.mbt
	typesNewFile bytes.Buffer
}

func (o *outBufsT) writeBuffersToFiles(baseDir string) {
	filePath := filepath.Join(baseDir, "types.mbt")
	writeFile(filePath, &o.typesFile)
	filePath = filepath.Join(baseDir, "types-json.mbt")
	writeFile(filePath, &o.typesJSONFile)
	filePath = filepath.Join(baseDir, "types-new.mbt")
	writeFile(filePath, &o.typesNewFile)
}

func writeFile(filePath string, buffer *bytes.Buffer) {
	f, err := os.Create(filePath)
	must(err)
	defer f.Close()
	_, err = buffer.WriteTo(f)
	must(err)
}
