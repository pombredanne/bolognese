module Bolognese
  module DataciteUtils
    def datacite_xml
      @datacite_xml ||= Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.resource(root_attributes) do
          insert_work(xml)
        end
      end.to_xml
    end

    def datacite_errors(xml: nil, schema_version: nil)
      schema_version ||= "http://datacite.org/schema/kernel-4"
      kernel = schema_version.to_s.split("/").last
      filepath = File.expand_path("../../../resources/#{kernel}/metadata.xsd", __FILE__)
      schema = Nokogiri::XML::Schema(open(filepath))

      schema.validate(Nokogiri::XML(xml, nil, 'UTF-8')).map { |error| error.to_s }.unwrap
    rescue Nokogiri::XML::SyntaxError => e
      e.message
    end

    def insert_work(xml)
      insert_identifier(xml)
      insert_creators(xml)
      insert_titles(xml)
      insert_publisher(xml)
      insert_publication_year(xml)
      insert_resource_type(xml)
      insert_alternate_identifiers(xml)
      insert_subjects(xml)
      insert_contributors(xml)
      insert_funding_references(xml)
      insert_dates(xml)
      insert_related_identifiers(xml)
      insert_version(xml)
      insert_rights_list(xml)
      insert_descriptions(xml)
    end

    def insert_identifier(xml)
      xml.identifier(doi, 'identifierType' => "DOI")
    end

    def insert_creators(xml)
      xml.creators do
        Array.wrap(author).each do |creator|
          xml.creator do
            insert_person(xml, creator, "creator")
          end
        end
      end
    end

    def insert_contributors(xml)
      return xml unless editor.present?

      xml.contributors do
        Array.wrap(editor).each do |contributor|
          xml.contributor("contributorType" => "Editor") do
            insert_person(xml, contributor, "contributor")
          end
        end
      end
    end

    def insert_person(xml, person, type)
      person_name = person["familyName"].present? ? [person["familyName"], person["givenName"]].compact.join(", ") : person["name"]

      xml.send(type + "Name", person_name)
      xml.givenName(person["givenName"]) if person["givenName"].present?
      xml.familyName(person["familyName"]) if person["familyName"].present?
      xml.nameIdentifier(person["id"], 'schemeURI' => 'http://orcid.org/', 'nameIdentifierScheme' => 'ORCID') if person["id"].present?
    end

    def insert_titles(xml)
      xml.titles do
        insert_title(xml)
      end
    end

    def insert_title(xml)
      xml.title(title)
    end

    def insert_publisher(xml)
      xml.publisher(publisher || container_title)
    end

    def insert_publication_year(xml)
      xml.publicationYear(publication_year)
    end

    def resource_type
      { "resource_type_general" => Metadata::SO_TO_DC_TRANSLATIONS[type] || "Other",
        "__content__" => additional_type || type }
    end

    def insert_resource_type(xml)
      return xml unless type.present?

      xml.resourceType(resource_type["__content__"],
        'resourceTypeGeneral' => resource_type["resource_type_general"])
    end

    def insert_alternate_identifiers(xml)
      return xml unless alternate_name.present?

      xml.alternateIdentifiers do
        Array.wrap(alternate_name).each do |alt|
          xml.alternateIdentifier(alt["name"], 'alternateIdentifierType' => alt["type"])
        end
      end
    end

    def insert_dates(xml)
      xml.dates do
        insert_date(xml, date_created, 'Created') if date_created.present?
        insert_date(xml, date_published, 'Issued') if date_published.present?
        insert_date(xml, date_modified, 'Updated') if date_modified.present?
      end
    end

    def insert_date(xml, date, date_type)
      xml.date(date, 'dateType' => date_type)
    end

    def insert_funding_references(xml)
      return xml unless Array.wrap(funding).present?

      xml.fundingReferences do
        Array.wrap(funding).each do |funding_reference|
          xml.fundingReference do
            insert_funding_reference(xml, funding_reference)
          end
        end
      end
    end

    def insert_funding_reference(xml, funding_reference)
      xml.funderName(funding_reference["name"]) if funding_reference["name"].present?
      xml.funderIdentifier(funding_reference["id"], "funderIdentifierType" => "Crossref Funder ID") if funding_reference["id"].present?
    end

    def insert_subjects(xml)
      return xml unless keywords.present?

      xml.subjects do
        keywords.each do |subject|
          xml.subject(subject)
        end
      end
    end

    def insert_version(xml)
      return xml unless version.present?

      xml.version(version)
    end

    def rel_identifier
      Array.wrap(related_identifier).map do |r|
        { "__content__" => r["id"] || r["issn"],
          "related_identifier_type" => r["issn"].present? ? "ISSN" : validate_url(r["id"]),
          "relation_type" => r["relationType"] }.compact
      end
    end

    def insert_related_identifiers(xml)
      return xml unless rel_identifier.present?

      xml.relatedIdentifiers do
        rel_identifier.each do |related_identifier|
          attributes = {
            'relatedIdentifierType' => related_identifier["related_identifier_type"],
            'relationType' => related_identifier["relation_type"] }.compact
          xml.relatedIdentifier(related_identifier["__content__"], attributes)
        end
      end
    end

    def insert_rights_list(xml)
      return xml unless license.present?

      xml.rightsList do
        Array.wrap(license).each do |lic|
          xml.rights(lic["name"], 'rightsURI' => lic["id"])
        end
      end
    end

    def insert_descriptions(xml)
      return xml unless description.present?

      xml.descriptions do
        Array.wrap(description).each do |des|
          xml.description(des["text"], 'descriptionType' => des["type"] || "Abstract")
        end
      end
    end

    def root_attributes
      { :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => 'http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd',
        :'xmlns' => 'http://datacite.org/schema/kernel-4' }
    end
  end
end
