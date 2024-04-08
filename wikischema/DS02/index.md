# DS02
This data set should be populated with the project's contractor functionally-based OBS identifiers for the entire span of the project (not the contract).<br/> Provide the contractor OBS identifiers in a hierarchical structure from the project level to the CA WBS level.<br/> The data should include all OBS identifiers in all other DSs in the same format. The data should align with dollarized RAM identifying intersections of CA WBS and OBS types.

| ------------ | ----------- |
| OBS_ID | Unique contractor OBS identifier. |
| title | Unique OBS identifier title. |
| level | OBS identifier hierarchical level relative to the project.<br/> The data is > 0, starting with 1 and increments of 1.<br/> The data should have only one level 1 OBS identifier, the OBS identifier representing the head of the contractor. |
| parent_OBS_ID | OBS identifier of the immediate hierarchical parent.<br/> Required unless DS02.level = 1. |
| external | OBS is external to the project (Y or N). |
| narrative | OBS identifier description from the EVMS cost tool.<br/> A short paragraph based on the functional OBS.<br/>Align with DS08.narrative. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
