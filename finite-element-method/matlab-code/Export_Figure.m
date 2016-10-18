function Export_Figure( h, paperWidth, paperHeight, FileName )

% Set figure size and print
set(h, 'PaperUnits', 'centimeters');
paperSize = get(h, 'PaperSize');
paperLeft = ( paperSize(1) - paperWidth ) / 2;
paperBottom = ( paperSize(2) - paperHeight ) / 2;
FigureSize = [paperLeft, paperBottom, paperWidth, paperHeight];
set(h, 'PaperPosition', FigureSize);

File_FIG = FileName;
File_PDF = FileName;

if length( File_FIG ) > 4 && ...
        strcmpi( File_FIG(end - 3):File_FIG( end ), '.pdf' ) == 0
    File_FIG = [File_FIG '.fig'];
    File_PDF = [File_PDF '.pdf'];
end;

saveas( h, File_FIG, 'fig' );
print( '-dpdf', '-r1200', File_PDF );