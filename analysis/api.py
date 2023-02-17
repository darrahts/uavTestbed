import psycopg2
import pandas as pd
import traceback
try:
    import package.utils as utils
except:
    import utils


class DB:
    """
        @brief: database interface class
        
        @properties:
            conn: psycopg2.extensions.connection
            cur: psycopg2.extensions.cursor 
    """
    
    def __init__(self, params: dict):
        """
            @brief: initializes a database connection wrapper object

            @params:
                params: a dictionary of database connection parameters
                    example:
                        from os import getlogin
                        from getpass import getpass

                        params={'user': getlogin(), 
                                'password': getpass(), 
                                'database': 'hmda_db',
                                'host': 'localhost',
                                'port': '5432'}
            
            @returns: none
        """
        self.conn = None
        self.cur = None
        self.connect(params)




    def connect(self, params: dict):
        """
            @brief: connects to the database

            @params:
                params: dictionary of db connection parameters
            
            @returns: none
        """
        try:
            print("[INFO] connecting to db.")
            conn = psycopg2.connect(**params)
            print("[INFO] connected.")
            cur = conn.cursor()
            self.conn = conn
            self.cur = cur
        except Exception as e:
            print("[ERROR] failed to connect to db.")
            print(e)
        del params
    


    
    def close(self):
        """
            @brief: closes the underlying connection and cursor
        """
        try:
            print('[INFO] closing db connection.')
            self.cur.close()
            self.conn.close()
        except Exception as e:
            print('[ERROR] failed to close the connection.')
            print(str(e))
            pass

    


    def execute(self, query: str) -> pd.DataFrame:
        """
            @brief: shorthand sql style execution, preferred method for select statements

            @params:
                query: the query string to execute
            
            @returns: a pandas table of the query results
        """
        try:
            return pd.read_sql_query(query, self.conn)
        except Exception as e:
            print(e)
            print(traceback.print_exc())
            if ('NoneType' in str(e)):
                print("ignoring error")
            return pd.DataFrame()



    def get_primary_key(self, tb: str):
        query = f"""SELECT c.column_name
    FROM information_schema.table_constraints AS t
        INNER JOIN information_schema.constraint_column_usage AS c
            ON t.constraint_name = c.constraint_name
            AND c.constraint_schema = t.table_schema
    WHERE t.constraint_type IN ('UNIQUE', 'PRIMARY KEY') 
         AND  t.table_schema = 'public' 
         AND t.table_name = '{tb}';"""
        
        return self.execute(query + ';')['column_name'].tolist()




    def update_tb(self, 
                  tb: str = None, 
                  sandbox: bool = True, 
                  verbose: bool = False,
                  df: pd.DataFrame = None):
        """
            @brief: updates a table tb with data from a datafame df

            @params:
                tb: the table to update
                df: the dataframe with the values to update

            @asserts:
                the first column of df must be a primary key of tb
            
            @returns:
                nothing

            @issues: the vals[j].replace ... line needs to check for dtypes, some int values might have commas
        """
        cols = (df.columns.tolist()[:])
        ### check if the first column is the primary key
        assert cols[0] in self.get_primary_key(tb=tb), '[ERROR] first column must be a primary key'
        for i, row in df.iterrows():
            vals = list(row.values)

            ### check if the key to update on is in the table
            res = self.execute(f"select * from {tb} where {cols[0]} = {int(vals[0])};")
            if len(res) > 0:
                try:
            
                    ### build the update statement
                    update_stmt = f"""update {tb} set """
                    for j in range(1, len(cols)):
                        if type(vals[j]) == type(1):
                            update_stmt += f""""{cols[j]}" = {int(vals[j])}, """
                        elif type(vals[j] == type('a')):
                            update_stmt += f""""{cols[j]}" = '{str(vals[j]).replace('+', '').replace("'", '')}', """
                        elif type(vals[j] == type(1.1)):
                            print(type(1.1), type(vals[j]), vals[j])
                            update_stmt += f""""{cols[j]}" = {float(vals[j])}, """
                    update_stmt = update_stmt[:-2] # removes last space and comma
                    update_stmt += f""" where "{cols[0]}" = {vals[0]};"""

                    ### execute the statement
                    if not sandbox:
                        self.cur.execute(update_stmt)
                        self.conn.commit()
                    
                    if verbose:
                        print(update_stmt)
                except Exception as e:
                    print(update_stmt)
                    print(cols)
                    print(vals)
                    print(e)
                    pass
                    if not sandbox:
                        self.conn.rollback()
                    print(e)
                    print(row)
                    break


    def insert_into_tb(self, 
                       tb:str = None, 
                       sandbox: bool = True, 
                       verbose:bool = False, 
                       df: pd.DataFrame = None):
        """
            @brief: inserts into a table tb with data from a datafame df

            @params:
                tb: the table to insert
                df: the dataframe with the values to update

            @returns:
                nothing
        """
        cols = str(tuple(df.columns.tolist()[:]))

        for i, row in df.iterrows():
            vals = str(row.values[:]).replace('[', '').replace(']', '').replace('\n','').replace(' ', ',')
            if verbose:
                print(vals)
            try:
                insert_stmt = f"""INSERT INTO {tb} {cols.replace("'", '"')} VALUES ({vals.replace('"', '')});"""
                if not sandbox:
                    self.cur.execute(insert_stmt)
                    self.conn.commit()
                else:
                    print(insert_stmt)
                    if i == 5:
                        break
            except Exception as e:
                if not sandbox:
                    self.conn.rollback()
                print(e)
                print(row)




    def get_tables(self) -> pd.DataFrame:
        """Returns a DataFrame of the tables in a given database"""
        query = """SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"""
        return self.execute(query + ';')




    def get_fields(self, 
                    tb: str = None,
                    as_list: bool = True,
                    get_dtypes: bool = False) -> pd.DataFrame or list:
            """
                @brief: returns the fields (column headers) for a given table
                
                @params:
                    tb<str>: the table to get fields
                    as_list<bool>: whether to return as a list or dataframe
                    get_dtypes<bool> whether to get the datatypes of the fields
                    
                @returns:
                    list or dataframe of fields
            """

            assert tb is not None, '[ERROR] must supply the name of the table (tb=__) and psycopg2.extensions.connection (db=__)'
            
            query = """select column_name"""
            if get_dtypes:
                query += """, data_type"""
                
            query += f""" FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = '{tb}' order by ordinal_position;"""
            res = self.execute(query)
            
            if as_list:
                fields = [col for col in res.column_name.values.tolist()]
                if get_dtypes:
                    dtypes = [col for col in res.data_type.values.tolist()]
                    return fields, dtypes
                else:
                    return fields
            else:
                return res




    def get_data(tb: str = None,
                    db: psycopg2.extensions.connection = None,
                    by: str = 'id',
                    **kwargs) -> pd.DataFrame:
            
        """
            @brief: returns a dataframe of data from the given table that match a given condition
            
            @params:
                tb <string> - the table to query
                db <psycopg2> - the database connection instance to the database
                by <string> - which table column to select by, default is 'id'
                kwargs - must match the 'by' param, must be a (column header) in the data table
                
            @returns:
                res <dataframe> - the result of the query as a dataframe
                
            @usage:
                get all data
                
                    get_data(tb='msa_tb', by='all', db=db)
                    
                        returns        	id	msa_md	city	state
                                    0	1	99999	Kirksville	MO
                                    1	2	99999	Hailey	ID
                                    ...
            
                single value condition
                    
                    get_data(tb='msa_tb', id=1, db=db)

                        returns         id msa_md     city     state
                                    0	1	99999	Kirksville	MO

                    get_data(tb='msa_tb', by='state', state='MO', db=db)

                        returns         id msa_md     city     state
                                    0	1	99999	Kirksville	MO
                                    1	119	27620	JeffersonCity	MO 
                                    ...
                                    
                    ...
                                    
                range comparison (i.e. val in (1,5) --> val == 1 or 2 or 3 or 4 or 5)
                    
                    get_data(tb='msa_tb',by='msa_md', msa_md=(16000,23105), db=db)
                    
                        returns        	id	msa_md	city	state
                                    0	7	16060	Carbondale-Marion	IL
                                    1	12	23104	Dallas-FortWorth	TX-OK
                                    ...
                    
                    ...
                    
                list of values comparison
                
                    get_data(tb='msa_tb', id=[1,2,14,24], db=db)
                    
                        returns        id	msa_md	city	state
                                    0	1	99999	Kirksville	MO
                                    1	2	99999	Hailey	ID
            
        """
        fields = DB.get_fields(tb, as_list=True, db=db)

        if by == 'all':
            query = f"""select tb.* from {tb} tb;"""
        
        elif by in kwargs.keys() and by in fields:
            if type(kwargs[by]) == type(1):
                query = f"""select tb.* from {tb} tb where tb."{by}" = {kwargs[by]};"""
            
            elif type(kwargs[by]) == type(' '):
                query = f"""select tb.* from {tb} tb where tb."{by}" = '{kwargs[by]}';"""
            
            elif type(kwargs[by]) == type(()):
                query = f"""select tb.* from {tb} tb where tb."{by}" between {kwargs[by][0]} and {kwargs[by][1]};"""
            
            elif type(kwargs[by] == type([])):
                query = f"""select tb.* from {tb} tb where tb."{by}" in {str(kwargs[by]).replace('[', '(').replace(']', ')')};"""
                
            else:
                return pd.DataFrame()
                          
        return DB.execute(query, db)




    def get_msa_mds(self, **kwargs) -> pd.DataFrame:
            """
                @brief: queries the database to retrieve metropolitan service area (msa) codes
                    and related information

                @params:
                    kwargs --> {
                        filter --> bool: filters out "unknown" msa values (-777 and 99999)
                        city --> str: retrieve data for a single city
                        state --> str: retrieve data for a single state
                        lar_count --> bool: calculate the total lar count by msa
                        <blank> --> ? other possiblities to be implemented
                    }

                returns:
                    pd.DataFrame(columns=[msa_md, lar_count, city, state])
                        
            """
            first_where = False
            if 'lar_count' in kwargs and kwargs['lar_count'] == True:
                query = f"""select tb.* from (select distinct(htb.msa_md), 
                                count(htb.*) as lar_count,
                                min(mtb.city) as "city",
                                min(mtb.state) as "state",
                                min(mtb.income) as "income"
                            from hmda_tb htb 
                            join msa_tb mtb on htb.msa_md = mtb.msa_md"""
            else:
                query = f"""select mtb.* from msa_tb mtb"""
            
            if 'filter' in kwargs and kwargs['filter'] == True:
                        query += """ where mtb.msa_md > 0 and mtb.msa_md < 99999"""
                        first_where = True
            
            if 'city' in kwargs and first_where == True:
                query += f""" and mtb.city ilike '%{kwargs['city']}%'"""
            elif 'city' in kwargs and first_where == False:
                query += f""" where mtb.city ilike '%{kwargs['city']}%'"""
                first_where = True

            if 'state' in kwargs and first_where == True:
                query += f""" and mtb.state ilike '%{kwargs['state']}%'"""
            elif 'state' in kwargs and first_where == False:
                query += f""" where mtb.state ilike '%{kwargs['state']}%'"""
                first_where = True

            if 'lei' in kwargs and len(lei == 20) and first_where == True:
                query += f""" and htb.lei = '{kwargs["lei"]}'"""
            elif 'lei' in kwargs and len(lei == 20) and first_where == False:
                query += f""" where htb.lei = '{kwargs["lei"]}'"""
                first_where = True

            if 'income_only' in kwargs and kwargs['income_only'] == True and first_where == True:
                query += f""" and mtb.income > 0"""
            elif 'income_only' in kwargs and kwargs['income_only'] == False and first_where == False:
                query += f""" where mtb.income > 0"""
                first_where = True
            
            
            if 'lar_count' in kwargs and kwargs['lar_count'] == True:
                query += """ group by htb.msa_md) tb
                            order by tb.lar_count desc"""
                
            if 'print_query' in kwargs and kwargs['print_query'] == True:
                print(query + ';')
            return self.execute(query + ';')




    def get_lenders(self, **kwargs):
        """
            @brief: queries the database to get a list of lenders

            @params:
                kwargs --> {
                    msa_md --> int: get lenders that service a given msa
                    order_by --> str: order by msa_lar_count, name, or total_lar_count
                    state --> str: get lenders that service a given state
                }

            @returns:
                pd.DataFrame(columns=[lei, name, msa_lar_count, total_lar_count])
        """
        first_where = False
        if 'all' in kwargs and kwargs['all'] == True:
            query = f"""select * from institution_tb itb"""

        else:
            query = f"""select distinct(htb.lei),  
                                min(itb."name") as name,
                                count(htb.*) as lar_count
                        from hmda_tb htb
                        join institution_tb itb on htb.lei = itb.lei"""
            
        if 'msa_md' in kwargs:      
            first_where = True     
            query += f""" where htb.msa_md = {kwargs['msa_md']}"""

        if 'state' in kwargs  and not first_where:
            first_where = True  
            query += f""" where htb.state_code ilike '%{kwargs["state"]}%'"""
        elif 'state' in kwargs and first_where == True:
            query += f""" and htb.state_code ilike '%{kwargs["state"]}"""

        if 'county' in kwargs and not first_where:
            first_where = True
            query += f""" where htb.county_code = {kwargs["county"]}"""
        elif 'county' in kwargs and first_where == True:
            query += f""" and htb.county_code = {kwargs["county"]}"""

        if 'name' in kwargs  and not first_where:
            first_where = True
            query += f""" where itb."name" ilike '%{kwargs["name"]}%'"""
        elif 'name' in kwargs and first_where == True:
            query += f""" and itb."name" ilike '%{kwargs["name"]}%'"""
        
        if 'all' not in kwargs:
            query += """ group by htb.lei"""
        
        if 'order_by' in kwargs:
            query += f""" order by "{kwargs['order_by']}" desc"""

        if 'print_query' in kwargs and kwargs['print_query'] == True:
            print(query + ';')

        return self.execute(query=query + ';')
    


        
    def get_lar_tracts(self, **kwargs):
        """
            @brief: queries the hmda_tb for records based on 0 or more conditions

            @params:
                kwargs --> {


                }

            @returns:

        """
        first_where = False
        query = f"""select distinct(htb.tract_id)"""

        if 'county' in kwargs:
            query += f""", min(ctt.state) as state,
						 min(ctt.county) as county"""

        if 'counts' in kwargs:
            if kwargs['counts'] == True:
                query += f""", count(htb.*) as lar_count"""

        if 'msa_md' in kwargs:
            query += f""", min(htb.msa_md) as msa_md"""
                
        if 'white_pct' in kwargs:
            if kwargs['white_pct'] == True:
                query += f""", min(act.white_pct) as white_pct"""

        if 'all_race_pct' in kwargs:
            if kwargs['all_race_pct'] == True:
                kwargs['white_pct'] = True
                query += f""", min(act.white_pct) as white_pct, 
                min(act.black_pct) as black_pct, 
                min(act.indian_pct) as indian_pct, 
                min(act.asian_pct) as asian_pct,
                min(act.hispanic_latino_pct) as hispanic_pct"""

        if 'population' in kwargs:
            if kwargs['population'] == True:
                query += f""", min(act.population) as population"""
        
        if 'income' in kwargs:
            if kwargs['income'] == True:
                query += f""", min(act.income) as income"""
                
        query += f""" from hmda_tb htb"""
  
        if 'white_pct' in kwargs or 'population' in kwargs or 'income' in kwargs:
            if kwargs['white_pct'] == True or kwargs['population'] == True or kwargs['income'] == True: 
                query += f""" join acs_tb act on htb.tract_id = act.tract_id"""

        
        if 'county' in kwargs:
            query += f""" join census_tract_tb ctt on htb.tract_id = ctt.tract_id 
                          where htb.state_code ilike '%{kwargs["county"]["state_abbr"]}'
                          and ctt.state ilike '%{kwargs["county"]["state"]}'
                          and htb.county_code = {kwargs["county"]["county_code"]}"""
            first_where = True


        if 'lei' in kwargs and first_where == False:
            query += f""" where htb.lei = '{kwargs["lei"]}'"""
            first_where = True
        elif 'lei' in kwargs and first_where == True:
            query += f""" and htb.lei = '{kwargs["lei"]}'"""
            
        if 'purpose' in kwargs:
            codes = []
            if 'purchase' in kwargs['purpose']:
                codes.append(1)
            if 'refi' in kwargs['purpose']:
                codes.append(31)
            if 'repair' in kwargs['purpose']:
                codes.append(2)
            if 'cashout' in kwargs['purpose']:
                codes.append(32)
        
            if len(codes) == 1:
                codes = f'({codes[0]})'
            else:
                codes = tuple(codes)
            if first_where == False:
                query += f""" where htb.loan_purpose in {codes}"""
                first_where = True
            else:
                query += f""" and htb.loan_purpose in {codes}"""
        
        if 'minority_only' in kwargs and first_where == False:
            query += f""" where act.white_pct < 50.0"""
            first_where = True
        elif 'minority_only' in kwargs and first_where == True:
            query += f""" and act.white_pct < 50.0"""
            
        if 'msa_md' in kwargs and first_where == False:
            query += f""" where htb.msa_md = {kwargs['msa_md']}"""
            first_where = True
        elif 'msa_md' in kwargs and first_where == True:
            query += f""" and htb.msa_md = {kwargs['msa_md']}"""

        if 'state' in kwargs and first_where == False:
            query += f""" where htb.state_code ilike '%{kwargs["state"]["state_abbr"]}%'"""
            first_where = True
        elif 'state' in kwargs and first_where == True:
            query += f""" and htb.state_code ilike '%{kwargs["state"]["state_abbr"]}%'"""
            
        if 'filter' in kwargs:
            if 'approvals' in kwargs['filter']:
                if first_where == False:
                    query += f""" where htb.action_taken in (1,2,6,8)"""
                    first_where = True
                else:
                    query += f""" and htb.action_taken in (1,2,6,8)"""
            if 'denials' in kwargs['filter']:
                if first_where == False:
                    query += f""" where htb.action_taken = 3"""
                    first_where = True
                else:
                    query += f""" and htb.action_taken = 3"""
            if 'denial_reason' in kwargs['filter']:
                reason_index = kwargs['filter'].index('denial_reason') + 1
                reason = kwargs['filter'][reason_index]
                if first_where == False:
                    query += f""" where (denial_reason_1 = {reason} or denial_reason_2 = {reason} or denial_reason_3 = {reason} or denial_reason_4 = {reason})"""
                    first_where = True
                else:
                    query += f""" and (denial_reason_1 = {reason} or denial_reason_2 = {reason} or denial_reason_3 = {reason} or denial_reason_4 = {reason})"""
            
        query += f""" group by htb.tract_id"""
        
        if 'action' in kwargs and kwargs['action'] == 'originated':
            query = "select tb.*, tb2.originations from (" + query + ") tb "
            query += "left outer join (select distinct(htb.tract_id), count(htb.*) as originations from hmda_tb htb where htb.action_taken = 1"
            
            if 'lei' in kwargs:
                query += f""" and htb.lei = '{kwargs["lei"]}'"""

            query += " group by htb.tract_id) tb2 on tb.tract_id = tb2.tract_id"

        else:
            query = "select tb.* from (" + query + ") tb "

        if 'order_by' in kwargs:
            query += f" order by tb.{kwargs['order_by']} desc"
            

        if 'print_query' in kwargs and kwargs['print_query'] == True:
            print(query + ';')
        return self.execute(query + ';')
    

    

    def get_denial_tracts(self, **kwargs):
        
        first_where = False
        
        query = f"""select tb.*, ct.reason_count from (select distinct(htb.tract_id)"""
        
        if 'county' in kwargs:
            query += f""", min(ctt.state) as state,
						 min(ctt.county) as county"""

        query += f""", count(htb.*) as denial_count,
                            min(htb.msa_md) as msa_md,
                            min(act.white_pct) as white_pct, 
                            min(act.population) as population, 
                            min(act.income) as income 
                        from hmda_tb htb 
                        join acs_tb act on htb.tract_id = act.tract_id"""

        first_where = False

        if 'county' in kwargs:
            query += f""" join census_tract_tb ctt on htb.tract_id = ctt.tract_id 
                          where htb.state_code ilike '%{kwargs["county"]["state_abbr"]}'
                          and ctt.state ilike '%{kwargs["county"]["state"]}'
                          and htb.county_code = {kwargs["county"]["county_code"]}"""
            first_where = True
        
        if 'lei' in kwargs and first_where == False:
            query += f""" where htb.lei = '{kwargs["lei"]}'"""
            first_where = True
        elif 'lei' in kwargs and first_where == True:
            query += f""" and htb.lei = '{kwargs["lei"]}'"""
        
        if 'msa_md' in kwargs and first_where == False:
            query += f""" where htb.msa_md = {kwargs['msa_md']}"""
            first_where = True
        elif 'msa_md' in kwargs and first_where == True:
            query += f""" and htb.msa_md = {kwargs['msa_md']}"""

        if 'state' in kwargs and first_where == False:
            query += f""" where htb.state_code ilike '%{kwargs["state"]}%'"""
            first_where = True
        elif 'state' in kwargs and first_where == True:
            query += f""" and htb.state_code ilike '%{kwargs["state"]}%'"""

        if not first_where:
            query = query + f""" where htb.action_taken = 3"""
        else:
            query = query + f""" and htb.action_taken = 3"""

        query = query +  f""" group by htb.tract_id) tb 
                        join (select distinct(htb.tract_id), 
                                    count(htb.*) as reason_count
                            from hmda_tb htb"""

        first_where = False
        if 'county' in kwargs:
            query += f""" join census_tract_tb ctt on htb.tract_id = ctt.tract_id 
                          where htb.state_code ilike '%{kwargs["county"]["state_abbr"]}'
                          and ctt.state ilike '%{kwargs["county"]["state"]}'
                          and htb.county_code = {kwargs["county"]["county_code"]}"""
            first_where = True

        if 'lei' in kwargs and first_where == False:
            query += f""" where htb.lei = '{kwargs["lei"]}'"""
            first_where = True
        elif 'lei' in kwargs and first_where == True:
            query += f""" and htb.lei = '{kwargs["lei"]}'"""
        
        if 'msa_md' in kwargs and first_where == False:
            query += f""" where htb.msa_md = {kwargs['msa_md']}"""
            first_where = True
        elif 'msa_md' in kwargs and first_where == True:
            query += f""" and htb.msa_md = {kwargs['msa_md']}"""

        if 'state' in kwargs and first_where == False:
            query += f""" where htb.state_code ilike '%{kwargs["state"]}%'"""
            first_where = True
        elif 'state' in kwargs and first_where == True:
            query += f""" and htb.state_code ilike '%{kwargs["state"]}%'"""

        if not first_where:
            query = query + f""" where htb.action_taken = 3"""
        else:
            query = query + f""" and htb.action_taken = 3"""

        query = query +  f""" and (denial_reason_1 = {kwargs['denial_reason']} or denial_reason_2 = {kwargs['denial_reason']} or denial_reason_3 = {kwargs['denial_reason']} or denial_reason_4 = {kwargs['denial_reason']}) 
                            group by htb.tract_id) ct 
                        on tb.tract_id = ct.tract_id
            order by tb.denial_count desc""" 

        if 'print_query' in kwargs and kwargs['print_query'] == True:
            print(query + ';')
        return self.execute(query + ';')



    def get_approval_denial_tracts(self, **kwargs):
        first_where = False
        query = f"""select tb.*, 
                           ct.denial_count, 
                           ft.lar_count 
                    from (select htb.tract_id"""

        if 'county' in kwargs:
            query += f""", min(ctt.state) as state,
						 min(ctt.county) as county"""
        
        query += f""", count(*) as approval_count,
                        min(act.white_pct) as white_pct, 
                        min(act.population) as population, 
                        min(act.income) as income 
                        from hmda_tb htb 
                        join acs_tb act on htb.tract_id = act.tract_id"""
        
        if 'county' in kwargs:
            query += f""" join census_tract_tb ctt on htb.tract_id = ctt.tract_id 
                          where htb.state_code ilike '%{kwargs["county"]["state_abbr"]}'
                          and ctt.state ilike '%{kwargs["county"]["state"]}'
                          and htb.county_code = {kwargs["county"]["county_code"]}"""
            first_where = True

        if 'lei' in kwargs and first_where == False:
            query += f""" where htb.lei = '{kwargs["lei"]}'"""
            first_where = True
        elif 'lei' in kwargs and first_where == True:
            query += f""" and htb.lei = '{kwargs["lei"]}'"""
        
        if 'state' in kwargs and first_where == False:
            query += f""" where htb.state_code ilike '%{kwargs["state"]}%'"""
            first_where = True
        elif 'state' in kwargs and first_where == True:
            query += f""" and htb.state_code ilike '%{kwargs["state"]}%'"""

        elif 'msa_md' in kwargs and first_where == False:
            query += f""" where htb.msa_md = {kwargs["msa_md"]}"""
            first_where = True
        elif 'msa_md' in kwargs and first_where == True:
            query += f""" and htb.msa_md = {kwargs["msa_md"]}"""

        first_where = False
        query = query + f""" and (action_taken = 1 or action_taken = 2) 
                    group by htb.tract_id) tb
            join (select htb.tract_id,
                    count(*) as denial_count 
                    from hmda_tb htb""" 


        if 'county' in kwargs:
            query += f""" join census_tract_tb ctt on htb.tract_id = ctt.tract_id 
                          where htb.state_code ilike '%{kwargs["county"]["state_abbr"]}'
                          and ctt.state ilike '%{kwargs["county"]["state"]}'
                          and htb.county_code = {kwargs["county"]["county_code"]}"""
            first_where = True

        if 'lei' in kwargs and first_where == False:
            query += f""" where htb.lei = '{kwargs["lei"]}'"""
            first_where = True
        elif 'lei' in kwargs and first_where == True:
            query += f""" and htb.lei = '{kwargs["lei"]}'"""
                
        if 'state' in kwargs and first_where == False:
            query += f""" where htb.state_code ilike '%{kwargs["state"]}%'"""
            first_where = True
        elif 'state' in kwargs and first_where == True:
            query += f""" and htb.state_code ilike '%{kwargs["state"]}%'"""

        elif 'msa_md' in kwargs and first_where == False:
            query += f""" where htb.msa_md = {kwargs["msa_md"]}"""
            first_where = True
        elif 'msa_md' in kwargs and first_where == True:
            query += f""" and htb.msa_md = {kwargs["msa_md"]}"""
        
        if not first_where:
            query += " where"
        else:
            query += " and"
        query += f""" action_taken = 3
                    group by htb.tract_id) ct
                on tb.tract_id = ct.tract_id 
                join (select htb.tract_id, count(*) as lar_count
                    from hmda_tb htb"""

        first_where = False
        if 'county' in kwargs:
            query += f""" join census_tract_tb ctt on htb.tract_id = ctt.tract_id 
                          where htb.state_code ilike '%{kwargs["county"]["state_abbr"]}'
                          and ctt.state ilike '%{kwargs["county"]["state"]}'
                          and htb.county_code = {kwargs["county"]["county_code"]}"""
            first_where = True

        if 'lei' in kwargs and first_where == False:
            query += f""" where htb.lei = '{kwargs["lei"]}'"""
            first_where = True
        elif 'lei' in kwargs and first_where == True:
            query += f""" and htb.lei = '{kwargs["lei"]}'"""
                
        if 'state' in kwargs and first_where == False:
            query += f""" where htb.state_code ilike '%{kwargs["state"]}%'"""
            first_where = True
        elif 'state' in kwargs and first_where == True:
            query += f""" and htb.state_code ilike '%{kwargs["state"]}%'"""

        elif 'msa_md' in kwargs and first_where == False:
            query += f""" where htb.msa_md = {kwargs["msa_md"]}"""
            first_where = True
        elif 'msa_md' in kwargs and first_where == True:
            query += f""" and htb.msa_md = {kwargs["msa_md"]}"""

        query += f""" group by htb.tract_id) ft
            on tb.tract_id = ft.tract_id
            order by ct.denial_count desc, tb.approval_count desc;"""

        if 'print_query' in kwargs and kwargs['print_query'] == True:
            print(query)
    
        return self.execute(query + ';')


    def get_tract_denial_ratio(self, **kwargs):
        query = f"""select a.tract_id, a.approvals, d.denials, 
        round((d.denials::float/a.approvals::float)::numeric, 3) as denial_ratio 
        from (select distinct(htb.tract_id), 
        count(htb.*) as denials
        from hmda_tb htb 
        where htb.lei  = '{kwargs["lei"]}'
        and htb.action_taken = 3
        group by htb.tract_id) d full outer join 
        (select distinct(htb.tract_id), 
        count(htb.*) as approvals
        from hmda_tb htb 
        where htb.lei  = '{kwargs["lei"]}'
        and htb.action_taken in (1,2,6,8)
        group by htb.tract_id) a on d.tract_id = a.tract_id"""
        
        if 'print_query' in kwargs and kwargs['print_query'] == True:
            print(query)
    
        return self.execute(query + ';')
    


    def get_counties(self, **kwargs):
        state = kwargs['state']

        query = f"""select min(ctt.state) as state, 
                    min(ctt.county) as county, 
                    min(ctt.county_code) as county_code,
                    avg(act.population)::integer as population,
                    round(avg(act.white_pct::numeric), 1) as white_pct,
                    avg(act.income)::integer as income
                from acs_tb act 
                join census_tract_tb ctt on act.tract_id = ctt.tract_id
                where ctt.state ilike '{state["state"]}'
                group by ctt.state, ctt.county_code
                order by ctt.state, ctt.county_code"""
        df1 = self.execute(query + ';')

        query = f"""select tb.* 
                from (select min(htb.state_code) as state_abbr, 
                            min(htb.county_code) as county_code, 
                            count(htb.*) as volume 
                        from hmda_tb htb
                        where htb.state_code ilike '{state["state_abbr"]}' and --htb.state_code not ilike '%-777' and 
                        htb.county_code != 777
                        group by htb.state_code, htb.county_code) tb
                    order by tb.volume"""

        df2 = self.execute(query + ';')

        return df1, df2
        
        
        
    def get_peers(self, **kwargs):
        
        if 'method' in kwargs and kwargs['method'] == 'standard':
            assert 'msa_md' in kwargs, '[ERROR] when method=standard msa_md must be supplied'
            assert 'msa_lar_count' in kwargs, '[ERROR] must supply msa_lar_count'
            query = f"""select tb.lei, 
                                tb.lar_count, 
                                itb."name" 
                        from 
                            (select distinct(lei), 
                            count(*) as lar_count 
                            from hmda_tb 
                            where msa_md = {kwargs['msa_md']}
                            group by lei) as tb 
                            join institution_tb itb on tb.lei = itb.lei 
                            where tb.lar_count >= .5 * {kwargs['msa_lar_count']}
                            and tb.lar_count <= 2 * {kwargs['msa_lar_count']}"""
            
        return self.execute(query + ';')
        
        
        
        
        
    ######################### WORK IN PROGRESS ###########################    
        
        
        




    @staticmethod
    def table_exists(tb: str = '',
                     db: psycopg2.extensions.connection = None) -> bool:
        query = f"""select * from information_schema.tables where table_schema = 'public' and table_name = '{tb}';"""
        res = DB.execute(query, db)
        if len(res.table_name.values) > 0:
            return True
        else:
            return False






    @staticmethod
    def batch_insert(df: pd.DataFrame = None,
                     tb: str = '',
                     num_batches: int = 10,
                     db: psycopg2.extensions.connection = None,
                     cur: psycopg2.extensions.cursor = None,
                     verbose: bool = False) -> int:
        """
        returns the id of the last record inserted
        """
        assert tb in DB.get_tables(db).values, f'[ERROR] table <{tb}> does not exist'
        assert all(col in DB.get_fields(f'{tb}', as_list=True, db=db) for col in list(df.columns)), f'[ERROR] target table <{tb}> does not contain all passed columns <{list(df.columns)}>'
        # about 100x faster than a for loop, 2x faster than using executemany or execute_batch
        # uses a generator to bypass memory issues
        for i, chunk in utils.chunk_generator(df, int(len(df)/num_batches)):
            values = list(tuple(x) for x in zip(*(chunk[x].values for x in list(df.columns))))
            if verbose:
                print(f"inserting batch {i} of {num_batches}...")
            vals = str(values).replace('[', '').replace(']', '')
            try:
                insert_stmt = f"""INSERT INTO {tb} {str(tuple(df.columns)).replace("'", '"')} VALUES {vals.replace('"', '')};"""
                cur.execute(insert_stmt)
                db.commit()
            except Exception as e:
                print(e)
                db.rollback()
                db.commit()
                return vals
        return DB.execute(f"select max(id) from {tb};", db).values[0][0]



    