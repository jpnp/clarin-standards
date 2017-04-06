xquery version "3.0";

module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema";

(: Define methods to access data in the schema
   @author margaretha
   @date Dec 2013
:)

declare variable $xsd:doc := doc('../schemas/spec.xsd');

(: Select relation types :)
declare function xsd:get-relations(){
    $xsd:doc/xs:schema/xs:element[@name="relation"]/xs:complexType/xs:attribute[@name="type"]/
    xs:simpleType/xs:restriction/xs:enumeration/data(@value)
};

(: Select status types :)
declare function xsd:get-statuses(){
    $xsd:doc/xs:schema/xs:element[@name="version"]/xs:complexType/xs:attribute[@name="status"]/
    xs:simpleType/xs:restriction/xs:enumeration/data(@value)
};

(: Select responsible types (e.g. author, editor, etc) :)
declare function xsd:get-resp(){
    $xsd:doc/xs:schema/xs:element[@name="respStmt"]/xs:complexType/xs:sequence/
    xs:element[@name="resp"]/xs:simpleType/xs:restriction/xs:enumeration/data(@value)
};

(: Select responsible entity types (e.g. person, org) :)
declare function xsd:get-resptype(){
    $xsd:doc/xs:schema/xs:element[@name="respStmt"]/xs:complexType/xs:sequence/
    xs:element[@name="name"]/xs:complexType/xs:simpleContent/xs:extension/
    xs:attribute[@name="type"]/xs:simpleType/xs:restriction/xs:enumeration/data(@value)

};

declare function xsd:get-clarinRecTypes(){
    $xsd:doc/xs:schema//xs:element[@name="recommendation"]/xs:complexType/xs:attribute[@name="type"]/
    xs:simpleType/xs:restriction/xs:enumeration/data(@value)
};
