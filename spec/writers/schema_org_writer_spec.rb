require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as schema_org" do
    it "journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.7554/elife.01567")
      expect(json["citation"].length).to eq(26)
      expect(json["citation"].first).to eq("@id"=>"https://doi.org/10.1038/nature02100", "@type"=>"CreativeWork", "name" => "APL regulates vascular tissue identity in Arabidopsis")
      expect(json["funding"]).to eq([{"name"=>"SystemsX", "@type"=>"Organization"},
                                     {"name"=>"EMBO",
                                      "@type"=>"Organization",
                                      "@id"=>"https://doi.org/10.13039/501100003043"},
                                     {"name"=>"Swiss National Science Foundation",
                                      "@type"=>"Organization",
                                      "@id"=>"https://doi.org/10.13039/501100001711"},
                                     {"name"=>"University of Lausanne",
                                      "@type"=>"Organization",
                                      "@id"=>"https://doi.org/10.13039/501100006390"}])
    end

    it "maremma schema.org JSON" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(json["author"]).to eq("name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner", "@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-0077-4738")
    end

    it "Schema.org JSON" do
      input = "https://doi.org/10.5281/ZENODO.48440"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5281/zenodo.48440")
      expect(json["name"]).to eq("Analysis Tools For Crossover Experiment Of Ui Using Choice Architecture")
    end

    it "Schema.org JSON isReferencedBy" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5061/dryad.8515")
      expect(json["@reverse"]).to eq("citation"=>{"@id"=>"https://doi.org/10.1371/journal.ppat.1000446"}, "isBasedOn"=>{"@id"=>"https://doi.org/10.1371/journal.ppat.1000446"})
    end

    it "Schema.org JSON IsSupplementTo" do
      input = "https://doi.org/10.5517/CC8H01S"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5517/cc8h01s")
      expect(json["@reverse"]).to eq("isBasedOn"=>{"@id"=>"https://doi.org/10.1107/s1600536804021154"})
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("R Interface to the DataONE REST API")
      expect(json["author"]).to eq([{"name"=>"Matt Jones",
                                     "givenName"=>"Matt",
                                     "familyName"=>"Jones",
                                     "@type"=>"Person",
                                     "@id"=>"http://orcid.org/0000-0003-0077-4738"},
                                    {"name"=>"Peter Slaughter",
                                     "givenName"=>"Peter",
                                     "familyName"=>"Slaughter",
                                     "@type"=>"Person",
                                     "@id"=>"http://orcid.org/0000-0002-2192-403X"},
                                    {"name"=>"University Of California, Santa Barbara", "@type"=>"Organization"}])
      expect(json["version"]).to eq("2.0.0")
    end

    it "Funding" do
      input = "https://doi.org/10.5438/6423"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/6423")
      expect(json["hasPart"].length).to eq(25)
      expect(json["hasPart"].first).to eq("@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5281/zenodo.30799")
      expect(json["funding"]).to eq("@type" => "Award",
                                    "funder" => {"@type"=>"Organization", "@id"=>"https://doi.org/10.13039/501100000780", "name"=>"European Commission"},
                                    "identifier" => "654039",
                                    "name" => "THOR – Technical and Human Infrastructure for Open Research",
                                    "url" => "http://cordis.europa.eu/project/rcn/194927_en.html")
    end

    it "Funding OpenAIRE" do
      input = "https://doi.org/10.5281/ZENODO.1239"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5281/zenodo.1239")
      expect(json["funding"]).to eq("@type" => "Award",
                                    "funder" => {"@type"=>"Organization", "@id"=>"https://doi.org/10.13039/501100000780", "name"=>"European Commission"},
                                    "identifier" => "246686")
    end
  end
end
