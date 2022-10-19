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
      Mu::AuthSudo.update(query)
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
      Mu::AuthSudo.update(query)
    end

    def select_account_by_session(session)
      query =  " SELECT ?session_id ?account_uri ?account_id ?person_status ?membership_id ?membership_status WHERE {"
      query += "   GRAPH <#{SESSIONS_GRAPH}> {"
      query += "     <#{session}> <#{MU_CORE.uuid}> ?session_id;"
      query += "                  <#{MU_SESSION.account}> ?account_uri ;"
      query += "                  <#{MU_EXT.sessionMembership}> ?membership_uri ."
      query += "   }"
      query += "   GRAPH <#{MOCK_ACCOUNT_GRAPH}> {"
      query += "     ?account_uri a <#{RDF::Vocab::FOAF.OnlineAccount}> ;"
      query += "              <#{MU_CORE.uuid}> ?account_id ."
      query += "     ?membership_uri a <#{ORG.Membership}> ;"
      query += "              <#{ORG.member}> ?person_uri ;"
      query += "              <#{MU_CORE.uuid}> ?membership_id ."
      query += "   }"
      query += "   GRAPH <#{SYSTEM_USERS_GRAPH}> {"
      query += "     ?person_uri <#{ADMS.status}> ?person_status ."
      query += "     ?membership_uri <#{ADMS.status}> ?membership_status ."
      query += "   }"
      query += " } LIMIT 1"
      Mu::AuthSudo.query(query)
    end

    def select_current_session(account)
      query =  " SELECT ?uri WHERE {"
      query += "   GRAPH <#{SESSIONS_GRAPH}> {"
      query += "     ?uri <#{MU_SESSION.account}> <#{account}> ;"
      query += "        <#{MU_CORE.uuid}> ?id . "
      query += "   }"
      query += " } LIMIT 1"
      Mu::AuthSudo.query(query)
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
      Mu::AuthSudo.update(query)
    end

    def select_login_data(account_id)
      query = %(
      SELECT ?account ?person ?person_id ?person_status ?organization ?organization_id ?membership ?membership_id ?membership_status
      WHERE {
        GRAPH <#{MOCK_ACCOUNT_GRAPH}> {
          ?account a <#{RDF::Vocab::FOAF.OnlineAccount}> ;
            <#{MU_CORE.uuid}> #{account_id.sparql_escape} .
          ?person <#{RDF::Vocab::FOAF.account}> ?account ;
            <#{MU_CORE.uuid}> ?person_id .
          ?membership <#{ORG.member}> ?person ;
            <#{MU_CORE.uuid}> ?membership_id ;
            <#{ORG.organization}> ?organization .
        }
        GRAPH <#{SYSTEM_USERS_GRAPH}> {
          ?person <#{ADMS.status}> ?person_status .
          ?membership <#{ADMS.status}> ?membership_status .
        }
      } LIMIT 1)
      Mu::AuthSudo.query(query)
    end

    def select_membership(user)
      query =  " SELECT ?membership ?membership_id ?status WHERE {"
      query += "   GRAPH <#{MOCK_ACCOUNT_GRAPH}> {"
      query += "     ?membership <#{ORG.member}> <#{user}> ; "
      query += "          <#{MU_CORE.uuid}> ?membership_id ."
      query += "   }"
      query += "   GRAPH <#{SYSTEM_USERS_GRAPH}> {"
      query += "     ?membership <#{ADMS.status}> ?status ."
      query += "   }"
      query += " } LIMIT 1"
      Mu::AuthSudo.query(query)
    end

    def select_organization(membership)
      query =  " SELECT ?status WHERE {"
      query += "   GRAPH <#{MOCK_ACCOUNT_GRAPH}> {"
      query += "     <#{membership}> <#{ORG.organization}> ?organization ."
      query += "   }"
      query += "   GRAPH <#{SYSTEM_USERS_GRAPH}> {"
      query += "     ?organization <#{ADMS.status}> ?status ."
      query += "   }"
      query += " } LIMIT 1"
      Mu::AuthSudo.query(query)
    end

    def insert_membership_block(membership)
      query = %(
      DELETE WHERE {
        GRAPH <#{SYSTEM_USERS_GRAPH}> {
          <#{membership}> <#{ADMS.status}> ?status .
        }
      })
      Mu::AuthSudo.update(query)
      query = %(
      INSERT DATA {
        GRAPH <#{SYSTEM_USERS_GRAPH}> {
          <#{membership}> <#{ADMS.status}> <#{BLOCKED_STATUS}> .
        }
      })
      Mu::AuthSudo.update(query)
    end
  end
end
