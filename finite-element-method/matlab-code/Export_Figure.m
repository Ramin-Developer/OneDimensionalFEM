function Export_Figure( h, paperWidth, paperHeight, FileName )

%EXPORT_FIGURE Export figure as .fig and .pdf with centered page layout.

% Set figure size and print
set(h, 'PaperUnits', 'centimeters');
paperSize = get(h, 'PaperSize');
paperLeft = ( paperSize(1) - paperWidth ) / 2;
paperBottom = ( paperSize(2) - paperHeight ) / 2;
FigureSize = [paperLeft, paperBottom, paperWidth, paperHeight];
set(h, 'PaperPosition', FigureSize);

File_FIG = FileName;
File_PDF = FileName;

if length(FileName) >= 4 && strcmpi(FileName(end-3:end), '.pdf')
    File_PDF = FileName;
    File_FIG = [FileName(1:end-4) '.fig'];
else
    File_FIG = [FileName '.fig'];
    File_PDF = [FileName '.pdf'];
end;

saveas( h, File_FIG, 'fig' );
print( '-dpdf', '-r1200', File_PDF );