xquery version "3.1";


(:~ This is the default application library module of the nedofiano app.
 :
 : @author Andrei Mihaila
 : @version 1.0.0
 : @see http://exist-db.org
 :)

(: Module for app-specific template functions :)
module namespace app="http://exist-db.org/return/nedofi/templates";

import module namespace templates = "http://exist-db.org/xquery/html-templating";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace myapp="http://example.com/app";



declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";


import module namespace lib = "http://exist-db.org/xquery/html-templating/lib";

import module namespace config = "http://exist-db.org/return/nedofi/config" at "config.xqm";

(: declare necessario per usare gli elementi tei nell'xml :)

(: creo una funzione per prendere il titolo :)

declare function app:footer($node as node(), $model as map (*))
{
    <img src="resources/images/unipi-logo-orizz.png" id="unipilogo" alt="existdb"/>
};

(: creo una funzione per prendere il publisher :)

declare function app:publisher($node as node(), $model as map (*))
{
    let $publisher := doc("/db/apps/nedofi/xml/Fiano_Codifica.xml")//tei:publicationStmt
    return <h4><i>{ $publisher//tei:publisher/text() }</i></h4>
};

(: creo una funzione per prendere tutti gli 'u' :)

declare function app:intervista($node as node(), $model as map(*)) {
  let $testimonianza := request:get-parameter("testimonianza", "")
  let $xmls := collection("/db/apps/nedofi/xml")/*
  let $testimonianza_ := replace($testimonianza, "\s+", "_")

  let $fileXML := (
    for $xml in $xmls
    let $testimone := $xml//tei:person[@role = 'testimone']
    let $forename := $testimone/tei:persName/tei:forename
    let $surname := $testimone/tei:persName/tei:surname
    where $forename = tokenize($testimonianza, '\s+')[1] and $surname = tokenize($testimonianza, '\s+')[2]
    return $xml
  )
  
  let $xslt := doc("/db/apps/nedofi/xslt/xslt.xsl")
  let $newHTML := transform:transform($fileXML, $xslt, ())
  
  return $newHTML
};



(: creo una funzione per recuperare il nome e il cognome di una persona a partire dal suo @xml:id dentro persName :)

declare function app:nome_persona_da_id($id_persona) {
    let $dati_persone := doc("/db/apps/nedofi/xml/Fiano_Codifica.xml")//tei:persName
    for $persona in $dati_persone 
    where $persona/@xml:id = $id_persona
    return data($persona) (: con data() si ottiene il contenuto testuale dell'elemento person, sia che sia nome / cognome o una descrizione:)
    };

(: questa funzione serve per evidenziare il fenomeno che mi interessa nell'enunciato :)    
    
declare function app:formatta_u_con_elementi($nodo_corrente as node(), $tipo as xs:string, $classe as xs:string) {
    let $localName := $nodo_corrente/local-name()
    return 
        (: se localName del nodo corrente è stringa vuota, è un nodo di testo semplice (non si evidenzia) :)
        if ($localName = "") then
            <span class="testo_default"> { data($nodo_corrente) } </span>
        else
            (: se localName del nodo corrente è del tipo da evidenziare, si evidenzia (via classe stile css) :)
            if ($localName = $tipo ) then
                <span class="{ $classe }"> { data($nodo_corrente) } </span>
            else
                (: altrimenti (cioè per tutti gli altri tipi di nodo) si effettua la ricorsione sui figli del nodo corrente:)
                <span>
                    {
                        for $nodo_figlio in $nodo_corrente/node()
                        return app:formatta_u_con_elementi($nodo_figlio, $tipo, $classe)
                    }
                </span>
};

(: lavoro con il regesto in maniera dinamica e automatica :)

(: creo una funzione dinamica e automatica che mi conta quante parti del regesto ci sono :)

declare function app:contaRegesti($node as node(), $model as map(*)) {
  let $testimonianza := request:get-parameter("testimonianza", "") (: es. Nedo Fiano :)
  let $testimonianza_ := replace($testimonianza, "\s+", "_") (: es. Nedo_Fiano :)
  let $xmlCollection := collection("/db/apps/nedofi/xml")
  let $count := count(
    for $xml in $xmlCollection/*
    let $testimone := $xml//tei:person[@role = 'testimone']
    let $forename := $testimone/tei:persName/tei:forename
    let $surname := $testimone/tei:persName/tei:surname
    where $forename = tokenize($testimonianza, '\s+')[1] and $surname = tokenize($testimonianza, '\s+')[2] (: dove $forename = $testimonianza[1] e $surname = $testimonianza[2]. Esempio: $forename = Nedo and $surname = Fiano :)
    let $timeline := $xml//tei:timeline[@xml:id = 'TL1']
    return $timeline//tei:when
  )
  return $count
};

(: creo una funzione dinamica che per ogni "item" dentro "list", mi crea un div :)

declare function app:restituisciRegesti($node as node(), $model as map(*)) {
  let $testimonianza := request:get-parameter("testimonianza", "") (: es. Nedo Fiano :)
  let $xmls := collection("/db/apps/nedofi/xml")/* (: Ottenere tutti i documenti XML nella cartella XML :)
  let $testimonianza_ := replace($testimonianza, "\s+", "_") (: es. Nedo_Fiano :)
  
  let $fileXML := (
    for $xml in $xmls
    let $testimone := $xml//tei:person[@role = 'testimone']
    let $forename := $testimone/tei:persName/tei:forename
    let $surname := $testimone/tei:persName/tei:surname
    where $forename = tokenize($testimonianza, '\s+')[1] and $surname = tokenize($testimonianza, '\s+')[2] (: dove $forename = $testimonianza[1] e $surname = $testimonianza[2]. Esempio: $forename = Nedo and $surname = Fiano :)
    return $xml
  )
  
  let $list := $fileXML//tei:abstract/tei:ab/tei:list
  let $timeline := $fileXML//tei:timeline[@xml:id="TL1"]

  for $i in 1 to count($list//tei:item)
    let $audio_id := "my-audio-" || $i
    let $item := $list//tei:item[$i]
    let $synch := $item/@synch/string()
    let $xml_id := tokenize($synch, '#')[2]
    let $inizio := $timeline//tei:when[@xml:id = $xml_id]/@absolute/string()
    let $fine := if ($i < count($list//tei:item)) then
      let $synch := $list//tei:item[$i + 1]/@synch/string()
      let $xml_id := tokenize($synch, "#")[2]
      let $prossimo_inizio := $timeline//tei:when[@xml:id = $xml_id]/@absolute/string()
      return $prossimo_inizio
    else ()
    let $div := element div {
      attribute class {"regesto-" || $i},
      attribute synch {$synch},
      $item,
      element span {
        attribute class {"minuto"},
        concat("Questa parte inizia al minuto: ", $inizio, if ($fine) then concat(" e finisce al minuto: ", $fine) else (" e continua fino alla fine dell'audio."))
      },
      element audio {
        attribute id {$audio_id}, 
        attribute controls {"controls"},
        attribute data-inizio {$inizio},
        attribute data-fine {$fine},
        element source {
          attribute src {concat("http://127.0.0.1/Audio/", $testimonianza_, ".mp3")}, 
          attribute type {"audio/mpeg"}
        }
      }
    }
    return $div
};



(: creo la funzione per il catalogo. Dentro la collection "xml" ci sono i file .xml. Per ogni file, creo un div :)

declare function app:creaCatalogo($node as node(), $model as map(*)) {
  for $xml in collection("/db/apps/nedofi/xml")/*
  let $testimone := $xml//tei:person[@role = 'testimone']
  let $nome-format0 := concat($testimone/tei:persName/tei:forename, '_', $testimone/tei:persName/tei:surname) (: es. Nedo_Fiano :)
  let $nome-format := replace($nome-format0, '_', ' ') (: es. Nedo Fiano :)
  let $wiki-link := concat("https://it.wikipedia.org/wiki/", $nome-format0)
  return
    <div class="catSing" onclick='riportaAllaTestimonianza("{$nome-format}")'>
        <h3>{concat("Testimonianza di ", $nome-format)}</h3>
        <img src="resources/images/noimage.jpeg" id="imgcat" alt="" data-testimone="{$nome-format0}"/> 
        <a id="hrefWiki" href="{$wiki-link}">Wikipedia</a>
    </div>
};


declare function app:creaTitoloCatalogo($node as node(), $model as map(*)) {
  let $testimonianza := request:get-parameter("testimonianza", "")
  let $nomeFile := replace($testimonianza, "\s+", "_")
  return
      <div id="divInd">
        <h1>Testimonianza di { $testimonianza }</h1>
        <img src="resources/images/noimage.jpeg" id="imgInd" alt="{concat("Immagine di ", $testimonianza)}" data-testimone="{$nomeFile}" />
        <button class="buttonCitazione" onclick="mostraCitazione()">Citazione</button>
        <p id="citazioneTesto"><i>L'Olocausto è una pagina del libro dell'Umanità da cui non dovremo mai togliere il segnalibro della memoria.</i><br/> - Primo Levi</p>
    </div>
};


(: creo una funzione che crea un audio HTML con la source di chi sta parlando :)

declare function app:creaAudio($node as node(), $model as map(*)) {
    let $testimonianza := request:get-parameter("testimonianza", "") (: es. Nedo_Fiano :)
    let $testimonianza_ := replace($testimonianza, "\s+", "_") (: es. Nedo_Fiano :)
    return 
        <audio id="audio-intervista" controls="controls">
                <source src="{concat("http://127.0.0.1/Audio/", $testimonianza_, ".mp3")}"/>
            </audio>
};













declare function app:if-attribute-set($node as node(), $model as map (*), $attribute as xs:string)
{
    let $isSet := (exists($attribute) and request:get-attribute($attribute))
    return
        if ($isSet) then
            templates:process($node/node(), $model)
        else
            ()
};

declare function app:if-attribute-unset($node as node(), $model as map (*), $attribute as xs:string)
{
    let $isSet := (exists($attribute) and request:get-attribute($attribute))
    return
        if (not($isSet)) then
            templates:process($node/node(), $model)
        else
            ()
};





declare function app:username($node as node(), $model as map (*))
{
    let $user := request:get-attribute("org.exist-db.mysec.user")
    let $name := if ($user) then sm:get-account-metadata($user, xs:anyURI('http://axschema.org/namePerson')) else 'Guest'
    return if ($name) then $name else $user
};

declare %templates:wrap function app:userinfo($node as node(), $model as map (*))
as map (*)
{
    let $user := request:get-attribute("org.exist-db.mysec.user")
    let $name := if ($user) then sm:get-account-metadata($user, xs:anyURI('http://axschema.org/namePerson')) else 'Guest'
    let $group := if ($user) then sm:get-user-groups($user) else 'guest'
    return
        map { "user-id" : $user, "user-name" : $name, "user-groups" : $group }
};


