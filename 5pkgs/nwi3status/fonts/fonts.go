package fonts

import (
	"bufio"
	"bytes"
	"errors"
	"fmt"
	"strings"
	"unicode"

	"barista.run/pango"
	"barista.run/pango/icons"
	"gopkg.in/yaml.v2"
)

func LoadMdi() error {
	mdi := icons.NewProvider("mdi")
	mdi.Font("Material Design Icons")
	mdi.AddStyle(func(n *pango.Node) { n.UltraLight() })
	started := false
	data, err := Asset("fonts/mdi_variables.scss")
	if err != nil {
		return err
	}
	s := bufio.NewScanner(bytes.NewReader(data))
	s.Split(bufio.ScanLines)
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		if !started {
			if strings.Contains(line, "$mdi-icons:") {
				started = true
			}
			continue
		}
		if line == ");" {
			return nil
		}
		colon := strings.Index(line, ":")
		if colon < 0 {
			return fmt.Errorf("Unexpected line '%s'", line)
		}
		name := strings.TrimFunc(line[:colon], func(r rune) bool {
			return unicode.IsSpace(r) || r == '"'
		})
		value := strings.TrimFunc(line[colon+1:], func(r rune) bool {
			return unicode.IsSpace(r) || r == ','
		})
		err = mdi.Hex(name, value)
		if err != nil {
			return err
		}
	}
	if !started {
		return errors.New("Could not find any icons in _variables.scss")
	}
	return errors.New("Expected ); to end $mdi-icons, got end of file")
}

type typiconsConfig struct {
	Glyphs []struct {
		Name string `yaml:"css"`
		Code string `yaml:"code"`
	} `yaml:"glyphs"`
}

func LoadTypicons() error {
	t := icons.NewProvider("typecn")
	t.Font("Typicons")
	var conf typiconsConfig

	data, err := Asset("fonts/typ_config.yml")
	if err != nil {
		return err
	}
	if err := yaml.NewDecoder(bytes.NewReader(data)).Decode(&conf); err != nil {
		return err
	}
	for _, glyph := range conf.Glyphs {
		if err := t.Hex(
			glyph.Name,
			strings.TrimPrefix(glyph.Code, "0x"),
		); err != nil {
			return err
		}
	}
	return nil
}

type faMetadata struct {
	Code   string   `yaml:"unicode"`
	Styles []string `yaml:"styles"`
}

func LoadFontAwesome() error {
	// Defaults to solid since that style has the most icons available.
	faSolid := icons.NewProvider("fa")
	faSolid.Font("Font Awesome 5 Free")
	faSolid.AddStyle(func(n *pango.Node) { n.Weight(900) })

	faBrands := icons.NewProvider("fab")
	faBrands.Font("Font Awesome 5 Brands")

	faRegular := icons.NewProvider("far")
	faRegular.Font("Font Awesome 5 Free")

	styles := map[string]*icons.Provider{
		"solid":   faSolid,
		"regular": faRegular,
		"brands":  faBrands,
	}

	data, err := Asset("fonts/fa5_icons.yml")
	if err != nil {
		return err
	}
	var glyphs map[string]faMetadata
	err = yaml.NewDecoder(bytes.NewReader(data)).Decode(&glyphs)
	if err != nil {
		return err
	}
	for name, meta := range glyphs {
		for _, style := range meta.Styles {
			p, ok := styles[style]
			if !ok {
				return fmt.Errorf("Unknown FontAwesome style: '%s'", style)
			}
			err = p.Hex(name, meta.Code)
			if err != nil {
				return err
			}
		}
	}
	return nil
}
