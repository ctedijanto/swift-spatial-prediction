##' Template of a \code{sl3} Learner.
##'
##' This is a template for defining a new learner.
##' This can be copied to a new file using \code{\link{write_learner_template}}.
##' The remainder of this documentation is an example of how you might write documentation for your new learner.
##' This learner uses \code{\link[spaMM]{spaMM}} from \code{spaMM} to fit my favorite machine learning algorithm.
##'
##' @docType class
##' @importFrom R6 R6Class
##' @export
##' @keywords data
##' @return Learner object with methods for training and prediction. See \code{\link{Lrnr_base}} for documentation on learners.
##' @format \code{\link{R6Class}} object.
##' @family Learners
##'
##' @section Parameters:
##' \describe{
##'   \item{\code{param_1="default_1"}}{ This parameter does something.
##'   }
##'   \item{\code{param_2="default_2"}}{ This parameter does something else.
##'   }
##'   \item{\code{...}}{ Other parameters passed directly to \code{\link[spaMM]{https://cran.r-project.org/web/packages/spaMM/spaMM.pdf}}. See its documentation for details.
##'   }
##' }
##'
##' @section Methods:
##' \describe{
##' \item{\code{special_function(arg_1)}}{
##'   My learner is special so it has a special function.
##'
##'   \itemize{
##'     \item{\code{arg_1}: A very special argument.
##'    }
##'   }
##'   }
##' }

# `call_with_args` function copied from https://github.com/tlverse/sl3/blob/master/R/utils.R
call_with_args <- function(fun, args, other_valid = list(), keep_all = FALSE) {
  if (!keep_all) {
    formal_args <- names(formals(fun))
    all_valid <- c(formal_args, other_valid)
    args <- args[which(names(args) %in% all_valid)]
  }
  do.call(fun, args)
}

Lrnr_spaMM <- R6Class(
  classname = "Lrnr_spaMM", inherit = Lrnr_base,
  portable = TRUE, class = TRUE,
  
  public = list(
    # you can define default parameter values here
    # if possible, your learner should define defaults for all required parameters
    initialize = function(outcome_formula = NULL,
                          outcome_covariates = c(), # eventually streamline outcome_formula / outcome_covariates
                          matern_covariates = c(),
                          method = "ML",
                          ...) {
      # this captures all parameters to initialize and saves them as self$params
      params <- args_to_list()
      super$initialize(params = params, ...)
    },

    # you can define public functions that allow your learner to do special things here
    # for instance glm learner might return prediction standard errors
    special_function = function(arg_1) {
    }
  ),
  
  private = list(
    # list properties your learner supports here.
    # Use sl3_list_properties() for a list of options
    .properties = c("binomial", "continuous"),

    # list any packages required for your learner here.
    .required_packages = c("spaMM"),

    # .train takes task data and returns a fit object that can be used to generate predictions
    .train = function(task) {
      # generate an argument list from the parameters that were
      # captured when your learner was initialized.
      # this allows users to pass arguments directly to your ml function
      args <- self$params
      
      # get outcome variable type
      # preferring learner$params$outcome_type first, then task$outcome_type
      outcome_type <- self$get_outcome_type(task)
      # should pass something on to your learner indicating outcome_type
      # e.g. family or objective
      
      ## family
      if (is.null(args$family)) {
        if (outcome_type$type == "continuous") {
          args$family <- gaussian
        } else if (outcome_type$type == "binomial") {
          args$family <- binomial
        } else {
          stop("Specified outcome type is unsupported in Lrnr_spaMM.")
        }
      }

      # add task data to the argument list
      # what these arguments are called depends on the learner you are wrapping
      # args$x <- as.matrix(task$X_intercept) # from template
      # args$y <- outcome_type$format(task$Y) # from template
      # below is workaround to create dataframe with all required 
      all_nodes <- unique(c(unlist(task$nodes), args$outcome_covariates, args$matern_covariates))
      args$data <- task$get_data(, columns = all_nodes, expand_factors = FALSE) # missing 'rows' signals warning, but CV does not work if rows=NULL (default)
      # auto prediction naming causes issues with as.formula; following lines replace problematic characters
      taboo_char <- "[~+=,()]"
      names(args$data) <- str_replace_all(names(args$data), taboo_char, "_")

      # only add arguments on weights and offset
      # if those were specified when the task was generated
      if (task$has_node("weights")) {
        args$weights <- NULL
        #print("Weights not used in Lrnr_spaMM.")
      }

      if (task$has_node("offset")) {
        #args$offset <- task$offset
        stop("Offset is unsupported in Lrnr_spaMM.")
      }
      
      ## formula
      # build formula argument from inputs
      formula <- ""
      if (length(task$nodes$covariates)>0){
        mod_covariates <- task$nodes$covariates
        mod_covariates <- str_replace_all(mod_covariates, taboo_char, "_") # replace problematic characters to match covariate names
        formula <- paste(args$outcome_formula, "~", paste(mod_covariates, collapse="+"))
      }
      if (length(args$matern_covariates)>0){
        formula <- paste(formula, "+Matern(1|", paste(args$matern_covariates, collapse = "+"), ")")
      }
      args$formula <- as.formula(formula)
      
      # call a function that fits your algorithm
      # with the argument list you constructed
      fit_object <- call_with_args(spaMM::fitme, args)

      # return the fit object, which will be stored
      # in a learner object and returned from the call
      # to learner$predict
      return(fit_object)
    },

    # .predict takes a task and returns predictions from that task
    .predict = function(task) {
      
      newdata_cols <- unique(c(task$nodes$covariates, self$params$matern_covariates))
      newdata_df <- task$get_data(, columns=newdata_cols, expand_factors=FALSE) # missing 'rows' signals warning, but CV does not work if rows=NULL (default)
      
      # replace problematic characters
      taboo_char <- "[~+=,()]"
      names(newdata_df) <- str_replace_all(names(newdata_df), taboo_char, "_")
      
      # binomial spaMM returns probabilities
      predictions <- stats::predict(
        private$.fit_object,
        newdata = newdata_df
      )
      predictions <- as.numeric(predictions)
      return(predictions)
    }
  )
)
