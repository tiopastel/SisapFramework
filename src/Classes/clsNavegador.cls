VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsNavegador"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Planilha As wsMapaMenusSisap
Private Tabela As ListObject
Private rngArvoreMenus As Range

Private Sub Class_Initialize()
    Set Planilha = wsMapaMenusSisap
    Set Tabela = Planilha.ListObjects("ArvoreMenus")
    Set rngArvoreMenus = Tabela.DataBodyRange
End Sub


Public Function AdicionaProximaTela()
    
    Dim adiciona As Boolean
    Dim Linha As Range
    Dim TelaProxima As clsTela
    Dim TelaAnterior As clsTela
    
    
    
    adiciona = True
    
    gsspSisap.Enter 1, 0
    
    Set TelaProxima = New clsTela
    
    For Each Linha In rngArvoreMenus.Rows
        
        If (TelaProxima.CodTela = Linha.Value2(1, 4)) And _
        (TelaProxima.CodPrograma = Linha.Value2(1, 3)) And _
        (TelaProxima.Titulo = Linha.Value2(1, 1)) Then
            adiciona = False
            Exit For
        End If
    Next Linha
    
    If adiciona Then
    
        Dim novaLinha As ListRow
        Set novaLinha = Tabela.ListRows.Add
        
        gsspSisap.F2 1, 0

        
        Set TelaAnterior = New clsTela
        
        For Each Linha In rngArvoreMenus.Rows
            If (TelaAnterior.CodTela = Linha.Value2(1, 4)) And _
            (TelaAnterior.CodPrograma = Linha.Value2(1, 3)) And _
            (TelaAnterior.Titulo = Linha.Value2(1, 1)) Then
                novaLinha.Range(6) = Linha.Value2(1, 2)
                Exit For
            End If
        Next Linha
        
        With novaLinha
            
            .Range(1) = TelaProxima.Titulo
            .Range(2) = novaLinha.Index
            .Range(3) = TelaProxima.CodPrograma
            .Range(4) = TelaProxima.CodTela
        
        End With
    Else
    
        MsgBox "A tela j� foi inserida no mapa"
    End If
        
End Function

Public Function BuscaTela(ByVal Indice As Long) As clsTela
    
    Set BuscaTela = New clsTela
    Dim Linha As Range
        
    For Each Linha In rngArvoreMenus.Rows
        
        If Indice = 0 Then
            Debug.Print "Foi passado um indice 0 para BuscaTela"
            Exit For
        ElseIf Indice > rngArvoreMenus.Rows.Count Then
            Debug.Print "Foi passado um indice fora do intervalo para a busca de tela"
            gsspSisap.JanelaErro "Ocorreu um erro ao situar a Tela no Mapa!"
            gsspSisap.EncerraSisap
            Exit For
        End If
        
        If (Linha.Value2(1, 2) = Indice) Then
            BuscaTela.Indice = Indice
            BuscaTela.AnteriorTela = CLng(Linha.Value2(1, 6))
            BuscaTela.ProximaTela = CLng(Linha.Value2(1, 5))
            BuscaTela.CodTela = Linha.Value2(1, 4)
            BuscaTela.CodPrograma = Linha.Value2(1, 3)
            BuscaTela.Titulo = Linha.Value2(1, 1)
            'Debug.Print "Retornando Tela Indice : " & Linha.Value2(1,  2).value
            Exit For
        End If
    Next Linha
    
End Function
Public Function LocalizaTela(ByRef Tela As clsTela)
'Procura na tabela de telas pelos c�digos e titulo se encontrar
'   preenche a tela passada no par�metro.
    Dim Linha As Range
    Dim i As Long
    i = 1
    
    For Each Linha In rngArvoreMenus.Rows
        If Tela.Equals(BuscaTela(i)) Then
            GoTo EncontrouTela
        End If
        i = i + 1
    Next Linha
    
    Debug.Print "N�o foi poss�vel encontrar a tela : " & vbNewLine _
    & Tela.Titulo & vbNewLine _
    & Tela.CodTela & vbNewLine _
    & Tela.CodPrograma
    
    gsspSisap.JanelaAlerta "N�o foi poss�vel localizar a Tela solicitada!" _
    & vbNewLine & "Por favor insira o caminho at� essa tela no sistema!"
    gsspSisap.EncerraSisap
    
EncontrouTela:

End Function
Public Function VoltaTela(ByRef Tela As clsTela, _
    Optional ByVal Ancestral As Integer)
    
    Do While (Tela.Indice <> Ancestral) And _
        (Tela.AnteriorTela <> 1)
        
        If Tela.AnteriorTela <> 1 Then
            gsspSisap.F2 1, 0
        Else
            gsspSisap.F3 1, 0
        End If
        
        Set Tela = gsspSisap.Tela
        
    Loop
    
    Set Tela = New clsTela
    LocalizaTela Tela
    
End Function

Public Function VoltaAncestralEmComum(ByRef Tela_Destino As clsTela) _
    As Integer
    
    Dim nav As New clsNavegador
    Dim tel1 As clsTela
    Dim telAux  As clsTela
    Dim voltarContador  As Integer
    
    Set tel1 = gsspSisap.Tela
    
    nav.LocalizaTela tel1
    voltarContador = 0
  
    Dim achou As Boolean
  
    Do While tel1.AnteriorTela <> 0 And _
        achou = False
        
        Set telAux = Tela_Destino
        
        Do While telAux.AnteriorTela <> 0
         
            If tel1.AnteriorTela = telAux.AnteriorTela Or _
            tel1.Indice = telAux.Indice Then
                achou = True
                voltarContador = voltarContador + 1
                VoltaAncestralEmComum = telAux.AnteriorTela
                GoTo AchouAncestralEmComum
                
            End If
            Set telAux = nav.BuscaTela(telAux.AnteriorTela)
        Loop
        
      voltarContador = voltarContador + 1
      Set tel1 = nav.BuscaTela(tel1.AnteriorTela)
    Loop
    
AchouAncestralEmComum:
    
    If (tel1.Indice = 1) Or _
        (voltarContador > 4) Or _
        (tel1.AnteriorTela = 1) Then
        Debug.Print "Voltando Tela Inicial."
        gsspSisap.TelaInicial
    Else
        Debug.Print "Voltar " & voltarContador & " Telas."
        nav.VoltaTela gsspSisap.Tela, VoltaAncestralEmComum
    End If
    Debug.Print "Ancestral Em Comum Tela " & VoltaAncestralEmComum
End Function

Public Function CaminhoParaTela(ByRef Tela As clsTela) As clstelsTela

    Dim telAux As clsTela
    Dim auxColletion As clstelsTela
    Dim indiceAux As Integer
    Dim Obj As Object
    Dim str As String
    Set CaminhoParaTela = New clstelsTela
    
    Set telAux = Tela
    
    Do While Not telAux.Indice = 0
        CaminhoParaTela.Add telAux
        Set telAux = BuscaTela(telAux.AnteriorTela)

    Loop
    
    Dim MyNewCol As New Collection
    For Each Obj In CaminhoParaTela.Collection
        If MyNewCol.Count > 0 Then
            MyNewCol.Add Item:=Obj, Before:=1
        Else
            MyNewCol.Add Item:=Obj
        End If
    Next
    
    CaminhoParaTela.Collection = MyNewCol
    
    For Each telAux In CaminhoParaTela.Collection
        str = str & telAux.Indice & ","
    Next
    
    Debug.Print "Ordem Descendente at� a tela : " & vbNewLine _
    & str
    
End Function