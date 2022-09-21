require_relative '/usr/src/app/sinatra_template/utils.rb'

module LoginService
  module SparqlQueries
    include SinatraTemplate::Utils

    def remove_old_sessions(session)
      query = " DELETE WHERE {"
      query += "   GRAPH <#{SESSIONS_GRAPH}> {"
      query += "     <#{session}> <#{MU_SESSION.account}> ?account ;"
      query += "                  <#{MU_CORE.uuid}> ?id ; "
      query += "                  <#{RDF::Vocab::DC.modified}> ?modified ; "
      query += "                  <#{MU_EXT.sessionMembership}> ?membership ."
      query += "   }"
      query += " }"
      update(query)
    end

    def insert_new_session_for_account(account, session_uri, session_id, membership_uri)
      now = DateTime.now

      query =  " PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>"
      query += " INSERT DATA {"
      query += "   GRAPH <#{SESSIONS_GRAPH}> {"
      query += "     <#{session_uri}> <#{MU_SESSION.account}> <#{account}> ;"
      query += "                      <#{RDF::Vocab::DC.modified}> #{now.sparql_escape} ;"
      query += "                      <#{MU_EXT.sessionMembership}> <#{membership_uri}> ;"
      query += "                      <#{MU_CORE.uuid}> #{session_id.sparql_escape} ."
      query += "   }"
      query += " }"
      update(query)
    end

    def select_account_by_session(session)
      query =  " SELECT ?session_id ?account_uri ?account_id ?membership_id WHERE {"
      query += "   GRAPH <#{SESSIONS_GRAPH}> {"
      query += "     <#{session}> <#{MU_CORE.uuid}> ?session_id;"
      query += "                  <#{MU_SESSION.account}> ?account_uri ;"
      query += "                  <#{MU_EXT.sessionMembership}> ?membership_uri ."
      query += "   }"
      query += "   GRAPH <#{MOCK_ACCOUNT_GRAPH}> {"
      query += "     ?account_uri a <#{RDF::Vocab::FOAF.OnlineAccount}> ;"
      query += "              <#{MU_CORE.uuid}> ?account_id ."
      query += "     ?membership_uri a <#{ORG.Membership}> ;"
      query += "              <#{MU_CORE.uuid}> ?membership_id ."
      query += "   }"
      query += " } LIMIT 1"
      query(query)
    end

    def select_current_session(account)
      query =  " SELECT ?uri WHERE {"
      query += "   GRAPH <#{SESSIONS_GRAPH}> {"
      query += "     ?uri <#{MU_SESSION.account}> <#{account}> ;"
      query += "        <#{MU_CORE.uuid}> ?id . "
      query += "   }"
      query += " } LIMIT 1"
      query(query)
    end

    def delete_current_session(account)
      query = " DELETE WHERE {"
      query += "   GRAPH <#{SESSIONS_GRAPH}> {"
      query += "     ?session <#{MU_SESSION.account}> <#{account}> ;"
      query += "              <#{MU_CORE.uuid}> ?id ; "
      query += "              <#{RDF::Vocab::DC.modified}> ?modified ; "
      query += "              <#{MU_EXT.sessionMembership}> ?membership ."
      query += "   }"
      query += " }"
      update(query)
    end

    def select_account_and_membership(account_id)
      query =  " SELECT ?account ?membership ?membership_id WHERE {"
      query += "   GRAPH <#{MOCK_ACCOUNT_GRAPH}> {"
      query += "     ?account a <#{RDF::Vocab::FOAF.OnlineAccount}> ;"
      query += "          <#{MU_CORE.uuid}> #{account_id.sparql_escape} ."
      query += "     ?person <#{RDF::Vocab::FOAF.account}> ?account ."
      query += "     ?membership <#{ORG.member}> ?person ; "
      query += "          <#{MU_CORE.uuid}> ?membership_id ."
      query += "   }"
      query += " } LIMIT 1"
      query(query)
    end
  end
end
