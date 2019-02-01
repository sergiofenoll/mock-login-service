require_relative '/usr/src/app/sinatra_template/utils.rb'

BESLUIT =  RDF::Vocabulary.new('http://data.vlaanderen.be/ns/besluit#')

module LoginConfig
  extend self

  def group_filter
      filter = "GRAPH <#{graph}> {"
      filter += "  ?group a <#{BESLUIT.Bestuurseenheid}> ;"
      filter += "           <#{MU_CORE.uuid}> ?group_uuid ."
      filter += "}"
  end

  def group_type_name
    "bestuurseenheden"
  end
  
end
    