## auc.jl (c) Area Under the ROC
## (c) 2016 David A. van Leeuwen
##
## Licensed under the MIT software license, see LICENSE.md

"""`AUC(::roc; pfa=1.0, pmiss=1.0, normalize=true)` computes the Area Under the Curve
with a sense `auc → 0` indicating better performance.

Optional parameters `pfa` or `pmiss` limit integration over only part of the ROC curve.
`normalize` indicates comparing the partial ROC to the trivial ROC.
"""
function auc(r::Roc; pfa=1.0, pmiss=1.0, normalize=true)
    if pfa != 1.0 || pmiss != 1.0
        if pfa !=1.0 && pmiss != 1.0 || ! (0.0 <= pfa <= 1.0) || !(0.0 <= pmiss <= 1.0)
            throw(DomainError)
        end
        if pfa < 1.0
            i = binsearch(-pfa, -r.pfa) ## find threshold where FAR = 0.
            norm = normalize ? 1/pfa/(2-pfa) : 1
            return -norm * dot(r.pmiss[i:end-1] + r.pmiss[i+1:end], diff(r.pfa[i:end])) / 2
        else
            i = binsearch(pmiss, r.pmiss)
            norm = normalize ? 1/pmiss/(2-pmiss) : 1
            return norm * dot(r.pfa[1:i-1] + r.pfa[2:i], diff(r.pmiss[1:i])) / 2
        end
    else
        ## The probability that a random non-target score is higher than a target score
        return -dot(r.pmiss[1:end-1] + r.pmiss[2:end], diff(r.pfa)) / 2
    end
end

auc(tar::Vector, non::Vector; kwargs...) = auc(roc(tar, non); kwargs...)

"""`AUC(::roc; pfa=1.0, pmiss=1.0, normalize=true)` computes the traditional Area Under the Curve
with a sense `AUC → 1` indicating better performance.

Optional parameters `pfa` or `pmiss` limit integration over only part of the ROC curve.
`normalize` indicates comparing the partial ROC to the trivial ROC.

You can also call this function as `AUC(targets::Vector, nontargets::Vector; kwargs...)`
"""
function AUC(args...; pfa=1.0, pmiss=1.0, normalize=true)
    if normalize
        return 1 - auc(args...; normalize=normalize, pfa=pfa, pmiss=pmiss)
    else
        return min(pfa, pmiss) - auc(args...; normalize=normalize, pfa=pfa, pmiss=pmiss)
    end
end
