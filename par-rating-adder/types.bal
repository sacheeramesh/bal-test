// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/sql;
import ballerinax/mysql;

# Database client configurations.
type DbClientConfig record {|
    # The username for the MySQL server
    string user;
    # The password for the MySQL server
    string password;
    # The name of the database
    string database;
    # The host of the MySQL server
    string host;
    # The port of the MySQL server
    int port;
    # The `mysql:Options` configurations
    mysql:Options options?;
    # The `sql:ConnectionPool` configurations
    sql:ConnectionPool connectionPool?;
|};

public type Employee record {
    string workEmail;
    string employeeName;
    string company;
    string location;
    string businessUnit;
    string department;
    string team;
    string subTeam;
    string managerEmail;
    int teamID;
};
