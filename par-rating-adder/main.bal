// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string encryptionKey = ?;
configurable int parCycleID = ?;
configurable DbClientConfig dbClientConfig = ?;
configurable string filePath = ?;

final mysql:Client dbClient = check new (...dbClientConfig);

@display {
    label: "PAR Rating Adder",
    id: "hris/par-rating-adder"
}

public function main() returns error? {
    string fileContent = check io:fileReadString(filePath);
    Employee[] employees = check fileContent.fromJsonStringWithType();
    log:printInfo(string `Data file successfully read : ${filePath}`);

    foreach Employee employee in employees {
        log:printInfo(string `Adding PAR record for : ${employee.workEmail}`);
        sql:ExecutionResult|sql:Error parRating = addParRatings(employee);
        if parRating is error {
            log:printError(string `Error in creating par ratings for : ${employee.workEmail}`, parRating);
        } else {
            log:printInfo(string `record Id : ${parRating.lastInsertId.toString()}`);
        }
    }

    log:printInfo("Data Migration completed!");
}

# Encryption.
#
# + value - Value to encrypt
# + return - sql:ParameterizedQuery
public isolated function getAesEncryptionValueQuery(string value) returns sql:ParameterizedQuery => `
    AES_ENCRYPT(${value}, ${encryptionKey})
`;

# Add default PAR rating record.
#
# + employee - Employee information
# + return - sql:ExecutionResult|sql:Error
public function addParRatings(Employee employee) returns sql:ExecutionResult|sql:Error {

    sql:ExecutionResult|sql:Error result = dbClient->execute(sql:queryConcat(`
            INSERT INTO hris.hris_par_rating (
                par_employee_email,
                par_employee_name,
                par_cycle_id,
                par_company,
                par_location,
                par_team_id,
                par_rating,
                par_special_rating,
                par_employee_status,
                par_lead_status,
                par_f2f_status,
                par_employee_acceptance_status,
                par_rating_created_by,
                par_rating_updated_by
            )
            VALUES (
                ${employee.workEmail},
                ${employee.employeeName},
                ${parCycleID},
                ${employee.company},
                ${employee.location},
                ${employee.teamID},`,
            getAesEncryptionValueQuery("NOT_ASSIGNED"), `,`,
            getAesEncryptionValueQuery("NOT_ASSIGNED"), `,`, `
                'PENDING',
                'PENDING',
                'PENDING',
                'PENDING',
                'SYSTEM',
                'SYSTEM'
            )
        `)
    );
    return result;
};
