package levels

import (
	"bytes"
	"fmt"
	"image/color"
	"strings"

	"github.com/icza/bitio"
)

// Level is a representation of a SkyRoads level.
type Level struct {
	Gravity, Fuel, Oxygen uint16
	Palette               [72]color.RGBA
	Road                  []Row
	Length                int
}

const (
	reset = "\033[0m"
	fg    = "\033[38;5;"
	bg    = "\033[48;5;"
)

// String prints a friendly representation of the level.
func (l Level) String() string {
	var s strings.Builder
	fmt.Fprintf(&s, "Gravity: %d, Fuel: %d, Oxygen: %d, Length: %d\n",
		l.Gravity, l.Fuel, l.Oxygen, len(l.Road))
	fmt.Fprintf(&s, "Palette: [")
	for _, p := range l.Palette {
		fmt.Fprintf(&s, "%s%dm %s ", bg, 16+36*(p.R)+6*(p.G)+(p.B), reset)
	}
	fmt.Fprintf(&s, " ]\n\n")
	for i := len(l.Road) - 1; i >= 0; i-- {
		r := l.Road[i]
		for _, c := range r {
			cs := ""
			if c.Bottom.R != 0 || c.Bottom.G != 0 || c.Bottom.B != 0 {
				cs += "x"
				if c.IsTunnel {
					cs += "t"
				}
				if c.IsHalfTop {
					cs += "h"
				}
				if c.IsFullTop {
					cs += "f"
				}
			}
			fmt.Fprintf(&s, "%s%dm %-5s %s",
				fg, 16+36*(c.Bottom.R)+6*(c.Bottom.G)+(c.Bottom.B), cs, reset)
		}
		fmt.Fprintf(&s, "\n")
	}
	return s.String()
}

// Row is a single line in the game (z-axis)
type Row [7]Cell

// Cell represent a single tile in the level.
type Cell struct {
	Bottom    color.RGBA
	Top       color.RGBA
	IsTunnel  bool
	IsHalfTop bool
	IsFullTop bool
}

// Parse reads a single level from the input reader.
// Level format reverse engineered on http://www.shikadi.net/moddingwiki/SkyRoads_level_format
func Parse(input *Reader, size int) (Level, error) {
	var l Level
	l.Gravity, _ = input.GetNum()
	l.Fuel, _ = input.GetNum()
	l.Oxygen, _ = input.GetNum()
	for i := 0; i < 72; i++ {
		r, _ := input.GetSmallNum()
		g, _ := input.GetSmallNum()
		b, _ := input.GetSmallNum()
		// This is a 6-bit VGA palette, but the numbers are 8-bit
		l.Palette[i] = color.RGBA{r << 2, g << 2, b << 2, 0}
	}

	road, _ := input.GetCompressedBytes(size)
	l.Length = len(road) / 2 / 7

	rdr := &Reader{bitio.NewReader(bytes.NewReader(road))}
	for i := 0; i < l.Length; i++ {
		var row Row
		for j := 0; j < 7; j++ {
			var cell Cell
			v, _ := rdr.GetNum()
			cell.Bottom = l.Palette[v&0x0F]
			cell.Top = l.Palette[(v>>4)&0x0F]
			cell.IsTunnel = (v>>8)&1 == 1
			cell.IsHalfTop = (v>>9)&1 == 1
			cell.IsFullTop = (v>>10)&1 == 1
			row[j] = cell
		}
		l.Road = append(l.Road, row)
	}

	return l, nil
}

func bitExtract(num uint16, start uint, len uint) int {
	return int(((1 << len) - 1) & (num >> (start - 1)))
}
