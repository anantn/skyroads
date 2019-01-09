package levels

import (
	"image/color"
)

// Level is a representation of a SkyRoads level.
type Level struct {
	Gravity, Fuel, Oxygen uint16
	Palette               [72]color.RGBA
	Road                  []byte
}

// Parse reads a single level from the input reader.
// Level format reverse engineered on http://www.shikadi.net/moddingwiki/SkyRoads_level_format
func Parse(input *Reader, size int) (Level, error) {
	var l Level
	l.Gravity, _ = input.GetNum()
	l.Fuel, _ = input.GetNum()
	l.Oxygen, _ = input.GetNum()
	for i := 0; i < 72; i++ {
		// * 4, why?
		r, _ := input.GetSmallNum()
		g, _ := input.GetSmallNum()
		b, _ := input.GetSmallNum()
		l.Palette[i] = color.RGBA{r, g, b, 0}
	}
	l.Road, _ = input.GetCompressedBytes(size)
	return l, nil
}
