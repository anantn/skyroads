package levels

import (
	"bytes"
	"encoding/binary"
	"io"
	"io/ioutil"

	"github.com/icza/bitio"
)

// Reader implement binary reading of common values from lzs files.
type Reader struct {
	source bitio.Reader
}

// GetNum returns a LE encoded 16bit integer.
func (r *Reader) GetNum() (v uint16, err error) {
	err = binary.Read(r.source, binary.LittleEndian, &v)
	return
}

// GetSmallNum returns a LE encoded 8bit integer.
func (r *Reader) GetSmallNum() (v uint8, err error) {
	err = binary.Read(r.source, binary.LittleEndian, &v)
	return
}

// GetBytes returns specified number of bytes.
func (r *Reader) GetBytes(length int) ([]byte, error) {
	b := make([]byte, length)
	n, err := r.source.Read(b)
	if n != length || err != nil {
		return nil, err
	}
	return b, nil
}

// GetCompressedBytes decompresses specified number of bytes from the input stream.
// Compression reverse engineered on http://www.shikadi.net/moddingwiki/SkyRoads_compression
func (r *Reader) GetCompressedBytes(length int) ([]byte, error) {
	b := make([]byte, length)
	width1, _ := r.GetSmallNum()
	width2, _ := r.GetSmallNum()
	width3, _ := r.GetSmallNum()

	for idx := 0; idx < length; {
		v, _ := r.source.ReadBool()
		if !v {
			dist, _ := r.source.ReadBits(width2)
			count, _ := r.source.ReadBits(width1)
			dist += 2
			count += 2
			copy(b[idx:], b[idx-int(dist):idx-int(dist)+int(count)])
			idx += int(count)
		} else {
			v, _ = r.source.ReadBool()
			if !v {
				dist, _ := r.source.ReadBits(width3)
				count, _ := r.source.ReadBits(width1)
				dist += 2 + (1 << width2)
				count += 2
				copy(b[idx:], b[idx-int(dist):idx-int(dist)+int(count)])
				idx += int(count)
			} else {
				d, _ := r.source.ReadByte()
				copy(b[idx:], []byte{d})
				idx++
			}
		}
	}

	r.source.Align()
	return b, nil
}

// Read a levels.lzs file from SkyRoads and return a list of Levels.
func Read(input io.Reader) ([]Level, error) {
	buf, err := ioutil.ReadAll(input)
	if err != nil {
		return nil, err
	}
	rdr := bytes.NewReader(buf)

	idx := 0
	end := 1
	var offsets [][2]uint16
	r := &Reader{bitio.NewReader(rdr)}
	for idx < end {
		start, err := r.GetNum()
		if err != nil {
			return nil, err
		}
		size, err := r.GetNum()
		if err != nil {
			return nil, err
		}
		if idx == 0 {
			end = int(start)
		}
		idx += 4
		offsets = append(offsets, [2]uint16{start, size})
	}

	levels := make([]Level, len(offsets))
	for i, o := range offsets {
		rdr.Seek(int64(o[0]), 0)
		l, err := Parse(r, int(o[1]))
		if err != nil {
			return nil, err
		}
		levels[i] = l
	}

	return levels, nil
}
