class Rule(object):
    """Base Rule class for rule-based analyzer"""
    def __init__(self, name='Rule'):
        self.name = name
        pass

    def __call__(self, variant, case=None, ontology=None):
        """ Main Rule function used to filter and score variants

        Args:
            variant: Current variant
            case: Case specific data
            ontology: Current ontology

        Returns:
            2-item tuple:
            score: Score, the main result of this rule
            evidence: Documentation of rule results
        """
        pass
    