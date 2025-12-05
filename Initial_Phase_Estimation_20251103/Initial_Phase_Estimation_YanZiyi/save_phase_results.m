function save_phase_results(paramGrid, paramNames, sweepVarName, sweepValues, ...
    mean_ml, std_ml, mean_dft, std_dft, mean_ls, std_ls, dftDisplayName, sweepLabel)

% 是否在命令行输出结果（true/false）
printToCmd = true;   

% 获取当前 m 文件的完整路径
currentFilePath = mfilename('fullpath');
[parentPath, ~, ~] = fileparts(currentFilePath);      % 当前文件所在文件夹
[parentPath1, parentFolder1, ~] = fileparts(parentPath); % 一级父文件夹
[parentPath2, parentFolder2, ~] = fileparts(parentPath1); % 二级父文件夹

% 拼接新的结果文件夹名：前两级父文件夹名 + PhaseEstimation_Results
% 判断是否有第二级父文件夹
if isempty(parentFolder2)
    prefixName = [parentFolder1 '_PhaseEstimation_Results'];
else
    prefixName = [parentFolder2 '_' parentFolder1 '_PhaseEstimation_Results'];
end

% 保存结果到 Excel（在当前路径下生成）
ts = datestr(now, 'yyyymmdd_HHMMSS');
resultsFolder = fullfile(pwd, prefixName);
if ~exist(resultsFolder, 'dir')
    mkdir(resultsFolder);
end
excelFileName = fullfile(resultsFolder, ['phase_est_results_' ts '.xlsx']);

% 参数说明（用于写入文件，便于记录）
paramPairs = cellfun(@(f) sprintf('%s=%s', f, mat2str(paramGrid.(f))), paramNames, 'UniformOutput', false);
paramLine = strjoin(paramPairs, '; ');

% Helper to build a block as cell array with consistent column count (numSweep+1)
build_block = @(methodName, paramLine, sweepVals, meanVals, varVals) ...
    [ repmat({''},1, numel(sweepVals)+1); ...
      [{['Method: ' methodName]}, repmat({''},1,numel(sweepVals))]; ...
      [{ ['Parameters: ' paramLine] }, repmat({''},1,numel(sweepVals))]; ...
      repmat({''},1,numel(sweepVals)+1); ...
      [{ sweepLabel }, num2cell(sweepVals)]; ...
      [{ 'Mean (deg)' }, num2cell(meanVals)]; ...
      [{ 'Std_Dev (deg)' }, num2cell(varVals)]; ...
      repmat({''},1, numel(sweepVals)+1) ];

% 构造3个块
block_ml  = build_block('Maximum Likelihood', paramLine, sweepValues, mean_ml, std_ml);
block_dft = build_block(dftDisplayName, paramLine, sweepValues, mean_dft, std_dft);
block_ls  = build_block('Least Squares', paramLine, sweepValues, mean_ls, std_ls);

% 合并为大单元格
big_cell = [block_ml; block_dft; block_ls];

% 写入 Excel 文件
writecell(big_cell, excelFileName);

% 提示完成
fprintf('Results saved to folder: %s\n', resultsFolder);
fprintf('Excel file: %s\n', excelFileName);

% 如果需要输出到命令行
if printToCmd
    fprintf('\n===== Phase Estimation Results =====\n');
    fprintf('Parameters: %s\n', paramLine);
    fprintf('Sweep variable (%s):\n', sweepLabel);
    disp(sweepValues);

    % 输出每种方法的结果
    print_block = @(methodName, meanVals, varVals) ...
        fprintf('\n--- %s ---\nMean (deg): %s\nStd_Dev (deg): %s\n', ...
            methodName, mat2str(meanVals), mat2str(varVals));

    print_block('Maximum Likelihood', mean_ml, std_ml);
    print_block(dftDisplayName, mean_dft, std_dft);
    print_block('Least Squares', mean_ls, std_ls);
    fprintf('====================================\n\n');
end

end
