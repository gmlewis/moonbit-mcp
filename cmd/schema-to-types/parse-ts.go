package main

import (
	"log"
	"strings"

	ord "github.com/wk8/go-ordered-map/v2"
)

// chunkify breaks up the MCP "schema.ts" file into individual chunks
// (keyed by concept name) for targeted subsequent parsing.
//
// Additionally, it returns a list of major categories for each section
// of the schema that can be used to break the types up into neatly-
// organized sections. Categories are keyed by the first concept name
// that starts the section (except for the very category which is keyed by "").
func chunkify(body string) (defs, categories *ord.OrderedMap[string, string]) {
	// first pass - break source into chunks based on double-newlines.
	chunks := strings.Split(body, "\n\n")
	chunks = consolidate(chunks)

	defs = ord.New[string, string](len(chunks))
	categories = ord.New[string, string]()

	// var lastConcept string
	for i, chunk := range chunks {
		lines := strings.Split(chunk, "\n")
		if lines[0] == "" {
			continue
		}
		category := extractCategory(lines[0])
		if i == 0 {
			categories.AddPairs(ord.Pair[string, string]{Key: "", Value: category})
			continue
		}

		concept := findConcept(chunk)
		if concept == "" {
			log.Fatalf("unable to find concept in chunk:\n%v", chunk)
		}
		// lastConcept = concept
		defs.AddPairs(ord.Pair[string, string]{Key: concept, Value: chunk})
		if category != "" {
			categories.AddPairs(ord.Pair[string, string]{Key: concept, Value: category})
		}
	}
	return defs, categories
}

func extractCategory(firstLine string) string {
	firstLine = strings.TrimSpace(firstLine)
	if strings.HasPrefix(firstLine, "//") {
		return strings.TrimSpace(strings.TrimPrefix(firstLine, "//"))
	}
	if !strings.HasPrefix(firstLine, "/*") || !strings.HasSuffix(firstLine, "*/") {
		return ""
	}
	return strings.TrimSpace(strings.TrimSuffix(strings.TrimPrefix(firstLine, "/*"), "*/"))
}

func consolidate(old []string) []string {
	chunks := make([]string, 0, len(old))

	var i int
	for {
		if i >= len(old) {
			break
		}
		chunk := strings.TrimSpace(old[i])
		i++
		if i == 1 {
			chunks = append(chunks, chunk)
			continue
		}
		// First, test if multiple entities are included in this one chunk, and if so, split them.
		exportConsts := strings.Split(chunk, "export const ")
		if len(exportConsts) > 2 {
			for j := 1; j < len(exportConsts); j++ {
				chunks = append(chunks, "export const "+strings.TrimSpace(exportConsts[j]))
			}
			continue
		}
		// Now see if we split the chunk at a bad place
		for {
			if i >= len(old)-1 {
				break
			}
			nextChunk := old[i]
			if len(nextChunk) > 0 && (nextChunk[0] == ' ' || nextChunk[0] == '\t') {
				// combine this next chunk into the current chunk separated by a blank
				// line and advance to the next chunk.
				chunk += "\n" + nextChunk
				i++
				continue
			}
			break
		}
		chunks = append(chunks, chunk)
	}

	return chunks
}

const (
	exportConst     = "export const "
	exportInterface = "export interface "
	exportType      = "export type "
)

func findConcept(chunk string) string {
	conceptAt := func(index int) string {
		i := strings.Index(chunk[index:], " ")
		if i < 0 {
			return ""
		}
		return chunk[index : index+i]
	}
	if i := strings.Index(chunk, exportConst); i >= 0 {
		return conceptAt(i + len(exportConst))
	}
	if i := strings.Index(chunk, exportInterface); i >= 0 {
		return conceptAt(i + len(exportInterface))
	}
	if i := strings.Index(chunk, exportType); i >= 0 {
		return conceptAt(i + len(exportType))
	}
	return ""
}
